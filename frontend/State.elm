module State exposing (init, update)

import Types exposing (..)
import Rest exposing (getRooms)
import Navigation exposing (Location)
import RemoteData


initialModel : Model
initialModel =
  { name = ""
  , rooms = RemoteData.Loading
  }


init : Location -> (Model, Cmd Msg)
init location =
  ( initialModel, getRooms )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    RoomsResponse rooms ->
      ( { model | rooms = rooms }, Cmd.none )
    LocationChanged _ ->
      ( model, Cmd.none )
    RequestRooms ->
      ( model, getRooms )