module View exposing (view)

import Types exposing (..)
import Html exposing (..)
import Views.Rooms exposing (roomsView)

view : Model -> Html Msg
view model =
  div []
    [ h1 []
      [ text "Hello world" ]
    , roomsView model.rooms
    ]
