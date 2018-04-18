module Main exposing (..)

import Navigation

import Types exposing (..)
import Ports exposing (..)
import View exposing (view)
import Subscriptions exposing (..)
import State exposing (init, update)


main : Program Flags Model Msg
main =
  Navigation.programWithFlags LocationChanged
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }