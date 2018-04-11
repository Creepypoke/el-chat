module Decoders exposing (..)

import Jwt
import Json.Decode exposing (int, string, Decoder, list, field, decodeString, maybe)
import Json.Decode.Pipeline exposing (decode, required, optional)

import Types exposing (..)


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
    |> required "id" string 
    |> required "from" userDecoder
    |> required "text" string
    |> required "kind" string