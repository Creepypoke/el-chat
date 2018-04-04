module Rest exposing (getRooms, signIn, signUp, decodeJwtString)

import Jwt
import Http
import Json.Decode exposing (int, string, Decoder, list, field)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import RemoteData

import Types exposing (..)


getRooms : Cmd Msg
getRooms =
  list roomDecoder
    |> Http.get "/api/rooms"
    |> RemoteData.sendRequest
    |> Cmd.map RoomsResponse


signUp : AuthForm -> Cmd Msg
signUp authForm =
  createSignUpRequest authForm
    |> Http.send SignedIn


signIn : AuthForm -> Cmd Msg
signIn authForm =
  createSignInRequest authForm
    |> Http.send SignedIn


roomDecoder : Decoder Room
roomDecoder =
  decode Room
    |> required "id" string
    |> required "name" string
    |> required "users" (list userDecoder)


userDecoder : Decoder User
userDecoder =
  decode User
    |> required "name" string


decodeJwtString : Maybe String -> Maybe JwtToken
decodeJwtString jwtString =
  case jwtString of
    Nothing ->
      Nothing
    Just jwtString ->
      Result.toMaybe
        (Jwt.decodeToken jwtDecoder jwtString)


jwtDecoder : Decoder JwtToken
jwtDecoder =
  decode JwtToken
    |> required "name" string
    |> required "iat" int


jwtResponseDecoder : Decoder JwtToken
jwtResponseDecoder =
  field "jwt" (Jwt.tokenDecoder jwtDecoder)


tokenStringDecoder : Decoder String
tokenStringDecoder =
  field "jwt" string


signUpEncoder : AuthForm -> Encode.Value
signUpEncoder auth =
  Encode.object
    [ ( "name", Encode.string auth.name )
    , ( "password", Encode.string auth.password )
    , ( "passwordConfirm", Encode.string auth.passwordConfirm )
    ]


signInEncoder : AuthForm -> Encode.Value
signInEncoder authForm =
  Encode.object
    [ ( "name", Encode.string authForm.name )
    , ( "password", Encode.string authForm.password )
    ]


createSignUpRequest : AuthForm -> Http.Request String
createSignUpRequest authForm =
  Http.post "/sign-up" (Http.jsonBody (signUpEncoder authForm)) tokenStringDecoder


createSignInRequest : AuthForm -> Http.Request String
createSignInRequest authForm =
  Http.post "/sign-in" (Http.jsonBody (signInEncoder authForm)) tokenStringDecoder