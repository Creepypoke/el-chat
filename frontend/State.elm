module State exposing (init, update)

import RemoteData
import Navigation exposing (Location, newUrl)

import Ports exposing (..)
import Types exposing (..)
import Rest exposing (getRooms, signIn, signUp, decodeJwtString)
import Routing exposing (extractRoute)


initialModel : Location -> Maybe String -> Model
initialModel location jwtString =
  { user = { name = "" }
  , rooms = RemoteData.Loading
  , currentRoute = extractRoute location
  , authForm = emptyAuthForm
  , jwt = decodeJwtString jwtString
  , jwtString = jwtString
  , messages = []
  }


emptyAuthForm : AuthForm
emptyAuthForm =
  { name = ""
  , password = ""
  , passwordConfirm = ""
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
    UpdateName newName ->
      ( { model | authForm = updateAuthFormName model.authForm newName }, Cmd.none )
    UpdatePassword newPassword ->
      ( { model | authForm = updateAuthFormPassword model.authForm newPassword }, Cmd.none )
    UpdatePasswordConfirm newPasswordConfirm ->
      ( { model | authForm = updateAuthFormPasswordConfirm model.authForm newPasswordConfirm }, Cmd.none )
    SubmitSignInForm ->
      ( model, signIn model.authForm )
    SubmitSignUpForm ->
      ( model, signUp model.authForm )
    SignedIn jwtString ->
      case jwtString of
        Result.Ok jwtString ->
          { model | jwtString = Just jwtString } |> update (SaveToken)
        Result.Err err ->
          let
            newMessages = toString(err) :: model.messages
          in
            ( { model | messages = newMessages }, Cmd.none )
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


updateAuthFormName : AuthForm-> String -> AuthForm
updateAuthFormName authForm newName =
  { authForm | name = newName }


updateAuthFormPassword : AuthForm -> String -> AuthForm
updateAuthFormPassword authForm password =
  { authForm | password = password }


updateAuthFormPasswordConfirm : AuthForm -> String -> AuthForm
updateAuthFormPasswordConfirm authForm passwordConfirm =
  { authForm | passwordConfirm = passwordConfirm }