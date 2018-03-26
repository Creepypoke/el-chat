module View exposing (view)

import Types exposing (..)
import Html exposing (..)


view : Model -> Html Msg
view model = 
  div []
    [ h1 []
      [ text "Hello world" ]
    ]