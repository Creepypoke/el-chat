module Ws exposing (parseWsMessageString)

import Json.Decode exposing (int, string, Decoder, list, field, decodeString)
import Json.Decode.Pipeline exposing (decode, required)

import Types exposing (..)


parseWsMessageString : String -> Cmd Msg
parseWsMessageString messageString =
  let
    message = decodeString int messageString
  in
    Cmd.none




