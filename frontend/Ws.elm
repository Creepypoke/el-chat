module Ws exposing (processWsMessageString)

import Types exposing (..)
import Decoders exposing (decodeWsMessage)

processWsMessageString : String -> Maybe Msg
processWsMessageString messageString =
  case decodeWsMessage messageString of
    Result.Ok wsMessage ->
      Just (NewMessage "wsMessage")
    Result.Err err ->
      Nothing



