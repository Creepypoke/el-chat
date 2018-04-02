module Rest exposing (getRooms, signIn, signUp)

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


signUp : Auth -> Cmd Msg
signUp auth = 
  createSignUpRequest auth
    |> Jwt.send SignedIn


signIn : Auth -> Cmd Msg
signIn auth =
  createSignInRequest auth
    |> Jwt.send SignedIn


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


jwtDecoder : Decoder JwtToken
jwtDecoder =
  decode JwtToken
    |> required "name" string


jwtResponseDecoder : Decoder JwtToken
jwtResponseDecoder =
  field "jwt" (Jwt.tokenDecoder jwtDecoder)


tokenStringDecoder : Decoder String
tokenStringDecoder =
  field "jwt" string
  

signUpEncoder : Auth -> Encode.Value
signUpEncoder auth = 
  Encode.object
    [ ( "name", Encode.string auth.name )
    , ( "password", Encode.string auth.password )
    , ( "passwordConfirm", Encode.string auth.passwordConfirm )
    ]


signInEncoder : Auth -> Encode.Value
signInEncoder auth =
  Encode.object 
    [ ( "name", Encode.string auth.name )
    , ( "password", Encode.string auth.password )
    ]


createSignUpRequest : Auth -> Http.Request JwtToken
createSignUpRequest auth = 
  Http.post "/sign-up" (Http.jsonBody (signUpEncoder auth)) jwtResponseDecoder


createSignInRequest : Auth -> Http.Request JwtToken
createSignInRequest auth =
  Http.post "/sign-in" (Http.jsonBody (signInEncoder auth)) jwtResponseDecoder