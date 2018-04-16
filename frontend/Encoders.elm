module Encoders exposing (..)

import Json.Encode exposing (..)

import Types exposing (..)


signUpEncoder : AuthForm -> Value
signUpEncoder auth =
  object
    [ ( "name", string auth.name )
    , ( "password", string auth.password )
    , ( "passwordConfirm", string auth.passwordConfirm )
    ]


signInEncoder : AuthForm -> Value
signInEncoder authForm =
  object
    [ ( "name", string authForm.name )
    , ( "password", string authForm.password )
    ]


newRoomEncoder : NewRoomForm -> Value
newRoomEncoder newRoomForm =
  object
    [ ( "name", string newRoomForm.name ) ]


messageToSendEncoder : MessageToSend -> Value
messageToSendEncoder messageToSend =
  object
    [ ( "roomId", string messageToSend.roomId)
    , ( "kind", encodeMessageKind messageToSend.kind)
    , ( "text", encodeMaybeString messageToSend.text)
    ]


encodeMessageKind : MessageKind -> Value
encodeMessageKind messageKind =
  case messageKind of
    Join ->
      string "join"
    Leave ->
      string "leave"
    Text ->
      string "text"


encodeMaybeString : Maybe String -> Value
encodeMaybeString maybeString =
  case maybeString of
    Just justString ->
      string justString
    Nothing ->
      null