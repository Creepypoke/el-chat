module Subscriptions exposing (..)

import WebSocket

import Types exposing (..)


subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen model.wsUrl NewMessage