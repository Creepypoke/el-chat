module State exposing (init, update)

import Http
import Debug
import RemoteData exposing (WebData)
import Navigation exposing (Location, newUrl)


import Ports exposing (..)
import Types exposing (..)
import Routing exposing (extractRoute)
import Decoders exposing (decodeJwtString, decodeErrorMessages, decodeWsMessage)
import Rest exposing (getRooms, signIn, signUp, createRoom)


initialModel : Location -> Maybe String -> Model
initialModel location jwtString =
  { rooms = RemoteData.Loading
  , currentRoute = extractRoute location
  , authForm = emptyAuthForm
  , newRoomForm = emptyNewRoomForm
  , jwt = decodeJwtString jwtString
  , jwtString = jwtString
  , messages = []
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


init : Maybe String -> Location -> (Model, Cmd Msg)
init jwt location =
  ( initialModel location jwt, getRooms )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    RoomsResponse rooms ->
      ( { model | rooms = rooms }, Cmd.none )
    LocationChanged location ->
      ( { model | currentRoute = extractRoute location }, Cmd.none )
    RequestRooms ->
      ( model, getRooms )
    JoinRoom room ->
      ( model, Cmd.none )
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
    UpdateNewRoomForm field value ->
      case field of
        Name ->
          ( { model | newRoomForm = updateNewRoomFormName model.newRoomForm value }, Cmd.none )
        _ ->
          ( model, Cmd.none )
    SubmitSignInForm ->
      ( model, signIn model.authForm )
    SubmitSignUpForm ->
      ( model, signUp model.authForm )
    SubmitNewRoomForm ->
      ( model, createRoom model.newRoomForm )
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
      let
        room = findRoom model.rooms wsMessage.roomId
        roomMessages = getRoomMessages room
        oneMessage = parseOneMessage wsMessage.message
        listMessages = parseListMessages wsMessage.messages
        messages = roomMessages ++ oneMessage ++ listMessages
      in
        case room of
          Just room ->
            { model | rooms = updateRoomMessages model.rooms room messages }
          Nothing ->
            model
    Result.Err err ->
      model


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


updateRoomMessages : WebData (List Room) -> Room -> List Message -> WebData (List Room)
updateRoomMessages rooms room messages =
  case rooms of
    RemoteData.Success rooms ->
      RemoteData.succeed (List.map
        (\n ->
          case n.id == room.id of
            True ->
              { n | messages = messages }
            False ->
              n
        ) rooms)
    _ ->
      rooms