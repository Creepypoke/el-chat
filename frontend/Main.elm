module Main exposing (..)

import State exposing (init, update)
import View exposing (view)
import Navigation
import Types exposing (..)


main : Program Never Model Msg
main = 
  Navigation.program LocationChanged
    { init = init
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }