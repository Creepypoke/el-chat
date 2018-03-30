module Utils exposing (..)

import Html exposing (Attribute)
import Html.Events exposing (onWithOptions)
import Json.Decode as Json
import Types exposing (..)


onClickNewUrl : String -> Attribute Msg
onClickNewUrl url =
  onWithOptions
    "click"
    { stopPropagation = True
    , preventDefault = True
    }
    (Json.succeed (NewUrl url))
