module Subscriptions exposing (..)

import WebSocket

import Types exposing (..)


subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://localhost:3000" NewMessage