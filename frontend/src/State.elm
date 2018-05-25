module State exposing (init, update)

import Http
import Debug
import WebSocket
import Json.Encode exposing (encode)
import RemoteData exposing (WebData)
import Navigation exposing (Location, newUrl)

import Ports exposing (..)
import Types exposing (..)
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
  { text = ""
  , showEmojiWidget = False
  , suggestions = []
  }


init : Flags -> Location -> (Model, Cmd Msg)
init flags location =
  let
    route = extractRoute location
    model = initialModel location flags
    msg = msgOnRoute route
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
        msg = nextMsg route model.currentRoute model.currentRoom
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
          |> andThen (RequestRecentMessages room)
    RequestRecentMessages room ->
      let
        messageToSend =
          { roomId = room.id
          , kind = Recent
          , text = Just "10"
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
            ( model, WebSocket.send model.wsUrl messageToSendString )
              |> andThen nextMsg
          Nothing ->
            ( model, WebSocket.send model.wsUrl messageToSendString )
    NewUrl url ->
      ( model, newUrl url )
    UpdateForm form field value ->
      ( updateModelForm model form field value
      , Cmd.none
      )
    SubmitForm form ->
      submitForm model form
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
      ( { model
        | jwt = Nothing
        , jwtString = Nothing
        }
      , Cmd.batch [ newUrl "/", removeJwt () ]
      )
    SaveToken ->
      case model.jwtString of
        Nothing ->
          update (NewUrl "/") model
        Just jwtString ->
          ( { model | jwt = decodeJwtString model.jwtString }
          , Cmd.batch [ newUrl "/", setJwt jwtString ]
          )
    NewWsMessage message ->
      case model.currentRoom of
        RemoteData.Success currentRoom ->
          let
            newCurrentRoom = processWsMessage currentRoom message
            newModel = { model | currentRoom = RemoteData.succeed newCurrentRoom }
          in
            ( newModel, Cmd.none )
        _ ->
          ( model, Cmd.none )
    ToggleEmojiWidget bool ->
      let
        newMessageForm =
          { text = model.newMessageForm.text
          , showEmojiWidget = bool
          , suggestions = model.newMessageForm.suggestions
          }
      in
        ( { model | newMessageForm = newMessageForm }, Cmd.none )


updateModelForm : Model -> Form -> Field -> String -> Model
updateModelForm model form field value =
  case form of
    Auth ->
      { model
      | authForm = updateAuthForm model.authForm field value
      }
    NewRoom ->
      { model
      | newRoomForm = updateNewRoomForm model.newRoomForm field value
      }
    NewMessage ->
      case model.currentRoom of
        RemoteData.Success currentRoom ->
          { model
          | newMessageForm = updateNewMessageForm model.newMessageForm currentRoom field value
          }
        _ ->
         model
    _ ->
      model


updateAuthForm : AuthForm -> Field -> String -> AuthForm
updateAuthForm authForm field value =
  case field of
    Name ->
      { authForm | name = value }
    Password ->
      { authForm | password = value }
    PasswordConfirm ->
      { authForm | passwordConfirm = value }
    _ ->
      authForm


updateNewRoomForm : NewRoomForm -> Field -> String -> NewRoomForm
updateNewRoomForm newRoomForm field value =
  case field of
    Name ->
      { newRoomForm | name = value }
    _ ->
      newRoomForm


updateNewMessageForm : NewMessageForm -> Room -> Field -> String -> NewMessageForm
updateNewMessageForm newMessageForm currentRoom field value =
  case field of
    MessageText ->
      showSuggestions currentRoom newMessageForm value
    Emoji ->
      let
        newText = newMessageForm.text ++ value
      in
        updateNewMessageFormText newMessageForm newText
    Mention ->
      setMention newMessageForm value
    _ ->
      newMessageForm


setMention : NewMessageForm -> String -> NewMessageForm
setMention form mentionString =
  let
    mentionsSections = (String.split "@" form.text)
    newMentionsSections = (List.take (List.length mentionsSections - 1) mentionsSections) ++ [ mentionString ++ " " ]
    newText = String.join "@" newMentionsSections
  in
    { form |
      text = newText,
      suggestions = []
    }


showSuggestions : Room -> NewMessageForm -> String -> NewMessageForm
showSuggestions room form value =
  let
    mentionsSections = String.split "@" value
    lastMention = List.head (List.reverse mentionsSections)
    formWithNewText = { form | text = value }
  in
    case (lastMention, value) of
      (Just mention, "") ->
        { formWithNewText
        | suggestions = []
        }
      (Just mention, _) ->
        { formWithNewText
        | suggestions = getSuggestions room.users mention
        }
      _ ->
        formWithNewText


getSuggestions : List User -> String -> List String
getSuggestions roomUsers filterStr =
  List.filter (\user -> String.startsWith filterStr user.name) roomUsers
    |> List.map (\user -> user.name)


submitForm : Model -> Form -> (Model, Cmd Msg)
submitForm model form =
  case form of
    SignIn ->
      ( model, signIn model.authForm )
    SignUp ->
      ( model, signUp model.authForm )
    NewRoom ->
      ( model, createRoom model.newRoomForm )
    NewMessage ->
      case model.currentRoom of
        RemoteData.Success room ->
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
        _ ->
         ( model, Cmd.none )
    Auth ->
      ( model, Cmd.none )


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
        , message = "Something went wrong"
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


processWsMessage : Room -> String -> Room
processWsMessage currentRoom wsMessageString =
  case decodeWsMessage wsMessageString of
    Result.Ok wsMessage ->
      if wsMessage.roomId == currentRoom.id then
        updateCurrentRoom currentRoom wsMessage
      else
        currentRoom
    Result.Err err ->
      currentRoom


updateCurrentRoom : Room -> WsMessage -> Room
updateCurrentRoom currentRoom wsMessage =
  let
    oneMessage = parseOneMessage wsMessage.message
    manyMessages = parseListMessages wsMessage.messages
    newMessages = oneMessage ++ manyMessages
  in
    List.foldr addMessage currentRoom newMessages


addMessage : Message -> Room -> Room
addMessage message room =
  case message.kind of
    Text ->
      { room | messages = message :: room.messages }
    Users ->
      case message.users of
        Just users ->
          { room | users = users }
        Nothing ->
          room
    _ ->
      room


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


msgOnRoute : Route -> Maybe Msg
msgOnRoute route =
  case route of
    RoomRoute roomId ->
      Just (RequestRoom roomId)
    HomeRoute ->
      Just RequestRooms
    SignOutRoute ->
      Just SignOut
    _ ->
      Nothing


nextMsg : Route -> Route -> WebData Room -> Maybe Msg
nextMsg nextRoute currentRoute currentRoom =
  let
    msg = msgOnRoute nextRoute
  in
    case currentRoute of
      RoomRoute roomId ->
        case currentRoom of
          RemoteData.Success room ->
            Just (LeaveRoom room msg)
          _ ->
            msg
      _ ->
        msg


andThen : Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
andThen msg ( model, cmd ) =
    let
      ( newmodel, newCmd ) =
        update msg model
    in
      newmodel ! [ cmd, newCmd ]
