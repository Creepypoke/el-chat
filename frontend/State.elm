module State exposing (init, update)

import Types exposing (..)
import Rest exposing (getRooms)
import Routing exposing (extractRoute)
import Navigation exposing (Location, newUrl)
import RemoteData


initialModel : Location -> Model
initialModel location =
  { name = ""
  , rooms = RemoteData.Loading
  , currentRoute = extractRoute location
  }


init : Location -> (Model, Cmd Msg)
init location =
  ( initialModel location, getRooms )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    RoomsResponse rooms ->
      ( { model | rooms = rooms }, Cmd.none )
    LocationChanged location ->
      ( { model | currentRoute = extractRoute location }, Cmd.none )
    RequestRooms ->
      ( model, getRooms )
    JoinRoom room ->
      ( model, Cmd.none )
    NewUrl url ->
      ( model, newUrl url )
