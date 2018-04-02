module Views.Helpers exposing (..)

import Html exposing (..)

import Types exposing (..)


ifAuthenticated : Model -> Html Msg -> Html Msg
ifAuthenticated model view =
  if model.auth.authenticated then
    view
  else
    text ""

