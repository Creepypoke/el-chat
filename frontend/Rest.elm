module Rest exposing (getRooms, signIn, signUp, createRoom)

import Http
import Json.Decode exposing (list, string)
import Json.Encode as Encode
import RemoteData

import Types exposing (..)
import Decoders exposing (..)


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


createRoom : NewRoomForm -> Cmd Msg
createRoom newRoomForm =
  createNewRoomRequest newRoomForm
    |> Http.send RoomCreated


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


newRoomEncoder : NewRoomForm -> Encode.Value
newRoomEncoder newRoomForm =
  Encode.object
    [ ( "name", Encode.string newRoomForm.name ) ]


createSignUpRequest : AuthForm -> Http.Request String
createSignUpRequest authForm =
  Http.post "/sign-up" (Http.jsonBody (signUpEncoder authForm)) tokenStringDecoder


createSignInRequest : AuthForm -> Http.Request String
createSignInRequest authForm =
  Http.post "/sign-in" (Http.jsonBody (signInEncoder authForm)) tokenStringDecoder


createNewRoomRequest : NewRoomForm -> Http.Request Room
createNewRoomRequest newRoomForm =
  Http.post "/api/rooms" (Http.jsonBody (newRoomEncoder newRoomForm)) roomDecoder