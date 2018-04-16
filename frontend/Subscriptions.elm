module Subscriptions exposing (..)

import WebSocket

import Types exposing (..)
import Settings exposing (..)


subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen wsUrl NewMessage