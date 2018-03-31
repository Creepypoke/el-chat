module Views.Rooms exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import RemoteData exposing (WebData)

import Types exposing (..)
import Views.Helpers exposing (..)
import Utils exposing (onClickNewUrl)

roomsView : WebData(List Room) -> Html Msg
roomsView rooms =
  div []
    [ h2 []
      [ text "Rooms" ]
    ,  viewRoomsOrError rooms
    ]


viewRoomsOrError : WebData(List Room) -> Html Msg
viewRoomsOrError roomsWebData =
  case roomsWebData of
    RemoteData.NotAsked ->
      text ""
    RemoteData.Loading ->
      text "Loading"
    RemoteData.Failure err ->
      text ("Error: " ++ toString err)
    RemoteData.Success rooms ->
      viewRooms rooms


viewRooms : List Room -> Html Msg
viewRooms rooms =
  div []
    (List.map roomView rooms)


roomView : Room -> Html Msg
roomView room =
  div []
    [ a [ onClickNewUrl (roomUrl room),  href (roomUrl room) ]
      [ text room.name ]
    , text (roomUsersCount room)
    ]

roomUsersCount : Room -> String
roomUsersCount room =
  " [" ++ toString (List.length room.users) ++"]"


roomUrl : Room -> String
roomUrl room =
  "/rooms/" ++ room.id