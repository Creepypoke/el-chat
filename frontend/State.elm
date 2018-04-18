module State exposing (init, update)

import Http
import Debug
import WebSocket
import Json.Encode exposing (encode)
import RemoteData exposing (WebData)
import Navigation exposing (Location, newUrl)

import Ports exposing (..)
import Types exposing (..)
import Utils exposing (..)
import Routing exposing (extractRoute)
import Decoders exposing (decodeJwtString, decodeErrorMessages, decodeWsMessage)
import Encoders exposing (messageToSendEncoder)
import Rest exposing (getRoom, getRooms, signIn, signUp, createRoom)


initialModel : Location -> Flags -> Model
initialModel location flags =
  { rooms = RemoteData.NotAsked
  , currentRoom = RemoteData.NotAsked
  , currentRoute = extractRoute location
  , authForm = emptyAuthForm
  , newRoomForm = emptyNewRoomForm
  , newMessageForm = emptyNewMessageForm
  , jwt = decodeJwtString flags.jwt
  , jwtString = flags.jwt
  , messages = []
  , wsUrl = flags.wsUrl
  }


emptyAuthForm : AuthForm
emptyAuthForm =
  { name = ""
  , password = ""
  , passwordConfirm = ""
  , errors = []
  }


emptyNewRoomForm : NewRoomForm
emptyNewRoomForm =
  { name = ""
  , errors = []
  }


emptyNewMessageForm : NewMessageForm
emptyNewMessageForm =
  { text = "" }


init : Flags -> Location -> (Model, Cmd Msg)
init flags location =
  let
    route = extractRoute location
    model = initialModel location flags
    msg = msgOnRoute route model
  in
    case msg of
      Nothing ->
        ( model, Cmd.none )
      Just msg ->
        update msg model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    RoomResponse room ->
      let
        newModel = { model | currentRoom = room }
      in
        case room of
          RemoteData.Success room ->
            update (JoinRoom room) newModel
          _ ->
            ( newModel, Cmd.none )
    RoomsResponse rooms ->
      ( { model | rooms = rooms }, Cmd.none )
    LocationChanged location ->
      let
        route = extractRoute location
        msg = nextMsg route model
        newModel = { model | currentRoute = route }
      in
        case msg of
          Just msg ->
            update msg newModel
          Nothing ->
            ( newModel, Cmd.none )
    RequestRoom roomId ->
      ( model, getRoom roomId )
    RequestRooms ->
      ( model, getRooms )
    JoinRoom room ->
      let
        messageToSend =
          { roomId = room.id
          , kind = Join
          , text = Nothing
          , jwt = model.jwtString
          }
        messageToSendString = encode 0 (messageToSendEncoder messageToSend)
      in
        ( model, WebSocket.send model.wsUrl messageToSendString )
    LeaveRoom room nextMsg ->
      let
        messageToSend =
          { roomId = room.id
          , kind = Leave
          , text = Nothing
          , jwt = model.jwtString
          }
        messageToSendString = encode 0 (messageToSendEncoder messageToSend)
      in
        case nextMsg of
          Just nextMsg ->
            andThen nextMsg
              <| ( model, WebSocket.send model.wsUrl messageToSendString )
          Nothing ->
            ( model, WebSocket.send model.wsUrl messageToSendString )
    NewUrl url ->
      ( model, newUrl url )
    UpdateAuthForm field value ->
      case field of
        Name ->
          ( { model | authForm = updateAuthFormName model.authForm value }, Cmd.none )
        Password ->
          ( { model | authForm = updateAuthFormPassword model.authForm value }, Cmd.none )
        PasswordConfirm ->
          ( { model | authForm = updateAuthFormPasswordConfirm model.authForm value }, Cmd.none )
        _ ->
          ( model, Cmd.none )
    UpdateNewRoomForm field value ->
      case field of
        Name ->
          ( { model | newRoomForm = updateNewRoomFormName model.newRoomForm value }, Cmd.none )
        _ ->
          ( model, Cmd.none )
    UpdateNewMessageForm field value ->
      case field of
        MessageText ->
          ( { model | newMessageForm = updateNewMessageFormText model.newMessageForm value }, Cmd.none )
        _ ->
          ( model, Cmd.none )
    SubmitSignInForm ->
      ( model, signIn model.authForm )
    SubmitSignUpForm ->
      ( model, signUp model.authForm )
    SubmitNewRoomForm ->
      ( model, createRoom model.newRoomForm )
    SubmitNewMessageForm room ->
      let
        messageToSend =
          { roomId = room.id
          , kind = Text
          , text = Just model.newMessageForm.text
          , jwt = model.jwtString
          }
        messageToSendString = encode 0 (messageToSendEncoder messageToSend)
      in
        ( { model | newMessageForm = emptyNewMessageForm }, WebSocket.send model.wsUrl messageToSendString)
    SignedIn jwtString ->
      case jwtString of
        Result.Ok jwtString ->
          { model | jwtString = Just jwtString } |> update (SaveToken)
        Result.Err err ->
          let
            errors = parseErr err
          in
            ( { model | authForm = updateAuthFormErrors model.authForm errors }, Cmd.none )

    RoomCreated room ->
      case room of
        Result.Ok room ->
          { model | newRoomForm = emptyNewRoomForm }
            |> update RequestRooms
        Result.Err err ->
          let
            errors = parseErr err
          in
            ( { model | newRoomForm = updateNewRoomFormErrors model.newRoomForm errors }, Cmd.none )
    SignOut ->
      let
        newModel =
          { model
          | jwt = Nothing
          , jwtString = Nothing
          }
      in
        ( newModel
        , Cmd.batch [ newUrl "/", removeJwt () ]
        )
    SaveToken ->
      case model.jwtString of
        Nothing ->
          update (NewUrl "/") model
        Just jwtString ->
          let
            jwt = decodeJwtString model.jwtString
          in
            ( { model | jwt = jwt }
            , Cmd.batch [ newUrl "/", setJwt jwtString ]
            )
    NewMessage message ->
      ( processWsMessage model message, Cmd.none )


updateAuthFormName : AuthForm-> String -> AuthForm
updateAuthFormName authForm newName =
  { authForm | name = newName }


updateAuthFormPassword : AuthForm -> String -> AuthForm
updateAuthFormPassword authForm password =
  { authForm | password = password }


updateAuthFormPasswordConfirm : AuthForm -> String -> AuthForm
updateAuthFormPasswordConfirm authForm passwordConfirm =
  { authForm | passwordConfirm = passwordConfirm }


updateAuthFormErrors : AuthForm -> List ErrorMessage -> AuthForm
updateAuthFormErrors authForm errors =
  { authForm | errors = errors }


updateNewRoomFormName : NewRoomForm -> String -> NewRoomForm
updateNewRoomFormName newRoomForm newName =
  { newRoomForm | name = newName }


updateNewRoomFormErrors : NewRoomForm -> List ErrorMessage -> NewRoomForm
updateNewRoomFormErrors newRoomForm errors =
  { newRoomForm | errors = errors }


updateNewMessageFormText : NewMessageForm -> String -> NewMessageForm
updateNewMessageFormText newMessageForm newText =
  { newMessageForm | text = newText }


parseErr : Http.Error -> List ErrorMessage
parseErr err =
  case err of
    Http.BadStatus response ->
      parseBadStatus response
    _ ->
      [
        { field = "General"
        , message = "Somethinh went wrong"
        }
      ]


parseBadStatus : Http.Response String -> List ErrorMessage
parseBadStatus response =
  case (decodeErrorMessages response.body) of
    Ok errors ->
      errors
    Err a->
      [
        { field = "General"
        , message = "Somethinh went wrong"
        }
      ]


processWsMessage : Model -> String -> Model
processWsMessage model wsMessageString =
  case decodeWsMessage wsMessageString of
    Result.Ok wsMessage ->
      case model.currentRoom of
        RemoteData.Success currentRoom ->
          if wsMessage.roomId == currentRoom.id then
            let
              roomMessages = currentRoom.messages
              oneMessage = parseOneMessage wsMessage.message
              listMessages = parseListMessages wsMessage.messages
              messages = roomMessages ++ oneMessage ++ listMessages
            in
              { model | currentRoom = updateCurrentRoomMessages currentRoom messages }
          else
            model
        _ ->
          model
    Result.Err err ->
      { model | messages = [toString(err)] }


findRoom : WebData (List Room) -> String -> Maybe Room
findRoom roomsWebData roomId =
  case roomsWebData of
    RemoteData.Success rooms ->
      List.filter (\n -> n.id == roomId) rooms
        |> List.head
    _ ->
      Nothing


getRoomMessages : Maybe Room -> List Message
getRoomMessages room =
  case room of
    Just room ->
      room.messages
    Nothing ->
      []


parseOneMessage : Maybe Message -> List Message
parseOneMessage message =
  case message of
    Just message ->
      [message]
    Nothing ->
      []


parseListMessages : Maybe (List Message) -> List Message
parseListMessages messages =
  case messages of
    Just messages ->
      messages
    Nothing ->
      []


updateCurrentRoomMessages : Room -> List Message -> WebData Room
updateCurrentRoomMessages room messages =
  RemoteData.succeed { room | messages = messages }


updateRoomMessages : WebData (List Room) -> Room -> List Message -> WebData (List Room)
updateRoomMessages rooms room messages =
  case rooms of
    RemoteData.Success rooms ->
      RemoteData.succeed (List.map
        (\n ->
          case n.id == room.id of
            True ->
              Debug.log "err" { n | messages = messages }
            False ->
              n
        ) rooms)
    _ ->
      rooms


msgOnRoute : Route -> Model -> Maybe Msg
msgOnRoute route model =
  case route of
    RoomRoute roomId ->
      Just (RequestRoom roomId)
      -- let
      --   room = findRoomById model.rooms roomId
      -- in
      --   case room of
      --     Just room ->
      --       Just (JoinRoom room)
      --     Nothing ->
      --       Nothing
    HomeRoute ->
      Just RequestRooms
    _ ->
      Nothing


nextMsg : Route -> Model -> Maybe Msg
nextMsg nextRoute model =
  let
    msg = msgOnRoute nextRoute model
  in
    case model.currentRoute of
      RoomRoute roomId ->
        let
          room = findRoomById model.rooms roomId
        in
          case room of
            Nothing ->
              msg
            Just room ->
              Just (LeaveRoom room msg)
      _ ->
        msg


andThen : Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
andThen msg ( model, cmd ) =
    let
        ( newmodel, newCmd ) =
            update msg model
    in
        newmodel ! [ cmd, newCmd ]
