module Decoders exposing (..)

import Jwt
import Json.Decode exposing (int, string, Decoder, list, field, decodeString, maybe, nullable, succeed, fail, andThen)
import Json.Decode.Pipeline exposing (decode, required, optional)

import Types exposing (..)


roomDecoder : Decoder Room
roomDecoder =
  decode Room
    |> required "id" string
    |> required "name" string
    |> required "users" (list userDecoder)
    |> required "messages" (list messageDecoder)


userDecoder : Decoder User
userDecoder =
  decode User
    |> required "name" string
    |> required "id" string


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
    |> required "id" string
    |> required "iat" int


jwtResponseDecoder : Decoder JwtToken
jwtResponseDecoder =
  field "jwt" (Jwt.tokenDecoder jwtDecoder)


tokenStringDecoder : Decoder String
tokenStringDecoder =
  field "jwt" string


wsMessageDecoder : Decoder WsMessage
wsMessageDecoder =
  decode WsMessage
    |> required "roomId" string
    |> required "message" (maybe messageDecoder)
    |> required "messages" (maybe (list messageDecoder))


messageDecoder : Decoder Message
messageDecoder =
  decode Message
    |> optional "id" (maybe string) Nothing
    |> required "datetime" string
    |> required "from" userDecoder
    |> required "text" string
    |> required "kind" messageKind


errorMessageDecoder : Decoder ErrorMessage
errorMessageDecoder =
  decode ErrorMessage
    |> required "field" string
    |> required "message" string


errorMessagesDecoder : Decoder (List ErrorMessage)
errorMessagesDecoder =
  list errorMessageDecoder


decodeErrorMessages : String -> Result String (List ErrorMessage)
decodeErrorMessages errorMessagesString =
  decodeString errorMessagesDecoder errorMessagesString


decodeWsMessage : String -> Result String (WsMessage)
decodeWsMessage wsMessageString =
  decodeString wsMessageDecoder wsMessageString


messageKind : Decoder MessageKind
messageKind =
  let
    convert : String -> Decoder MessageKind
    convert raw =
      case raw of
        "text" ->
          succeed Text
        "error" ->
          succeed Error
        "recent" ->
          succeed Recent
        _ ->
          fail <| "Unsupported message kind"
  in
      string |> andThen convert