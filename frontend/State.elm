module State exposing (init, update)

import Types exposing (..)
import Navigation exposing (Location)
import RemoteData


initialModel : Model
initialModel =
  { name = ""
  , rooms = RemoteData.Loading
  }


init : Location -> (Model, Cmd Msg)
init location =
  ( initialModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of 
    RoomsResponse rooms ->
      ( { model | rooms = rooms }, Cmd.none )
    _ ->
      ( model, Cmd.none )