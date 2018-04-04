module Main exposing (..)

import Navigation

import Types exposing (..)
import Ports exposing (..)
import View exposing (view)
import State exposing (init, update)

main : Program (Maybe String) Model Msg
main =
  Navigation.programWithFlags LocationChanged
    { init = init
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }