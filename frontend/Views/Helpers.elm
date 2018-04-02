module Views.Helpers exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href)

import Types exposing (..)
import Utils exposing (..)


link : String -> Html Msg -> List String -> Html Msg
link url content classes =
  a [onClickNewUrl url, href url ]
    [ content ]