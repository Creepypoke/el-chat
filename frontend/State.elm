module State exposing (init, update)

import Types exposing (..)
import Navigation exposing (Location)


initialModel : Model
initialModel =
  { name = "" }


init : Location -> (Model, Cmd Msg)
init location =
  ( initialModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  ( model, Cmd.none )