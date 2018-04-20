module Views.Helpers exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href)

import Types exposing (..)
import Utils exposing (..)


link : String -> Html Msg -> List String -> Html Msg
link url content classes =
  a [onClickNewUrl url, href url ]
    [ content ]

errors : List ErrorMessage -> Html Msg
errors formErrors =
  div []
    (List.map error formErrors)


error : ErrorMessage -> Html Msg
error errorMessage =
  div []
    [ strong []
      [ text (errorMessage.field ++ ":") ]
    , text ("  " ++ errorMessage.message)
    ]
