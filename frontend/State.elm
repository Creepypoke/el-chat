module State exposing (init, update)

import RemoteData
import Navigation exposing (Location, newUrl)

import Types exposing (..)
import Rest exposing (getRooms, signIn, signUp)
import Routing exposing (extractRoute)


initialModel : Location -> Model
initialModel location =
  { user = { name = "" }
  , rooms = RemoteData.Loading
  , currentRoute = extractRoute location
  , auth = emptyAuth
  , jwt = Nothing
  , messages = []
  }


emptyAuth : Auth
emptyAuth =
  { name = ""
  , password = ""
  , passwordConfirm = ""
  , authenticated = False
  }


init : Location -> (Model, Cmd Msg)
init location =
  ( initialModel location, getRooms )


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
      ( { model | auth = updateAuthName model.auth newName }, Cmd.none )
    UpdatePassword newPassword ->
      ( { model | auth = updateAuthPassword model.auth newPassword }, Cmd.none )
    UpdatePasswordConfirm newPasswordConfirm ->
      ( { model | auth = updateAuthPasswordConfirm model.auth newPasswordConfirm }, Cmd.none )
    SubmitSignInForm ->
      ( model, signIn model.auth )
    SubmitSignUpForm ->
      ( model, signUp model.auth )
    SignedIn res ->
      case res of
        Result.Ok jwt ->
          { model | jwt = Just jwt } |> update (NewUrl "/")
        Result.Err err ->
          let 
            newMessages = toString(err) :: model.messages
          in
            ( { model | messages = newMessages }, Cmd.none )


updateAuthName : Auth -> String -> Auth
updateAuthName auth newName =
  { auth | name = newName }


updateAuthPassword : Auth -> String -> Auth
updateAuthPassword auth password =
  { auth | password = password }


updateAuthPasswordConfirm : Auth -> String -> Auth
updateAuthPasswordConfirm auth passwordConfirm =
  { auth | passwordConfirm = passwordConfirm }