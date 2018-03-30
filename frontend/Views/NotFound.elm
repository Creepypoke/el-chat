module Views.NotFound exposing (notFoundView)

import Html exposing (..)
import Types exposing (..)

notFoundView : Html Msg
notFoundView =
  div []
    [ h1 []
        [ text "Page not found" ]
    ]