module Views.Rooms exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Types exposing (..)
import RemoteData exposing (WebData)

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
    [ a [ href ("#" ++ room.id) ]
      [ text room.name ]
    , text (roomUsersCount room)
    , button [ onClick (JoinRoom room) ] 
        [ text "Join" ]
    ]


roomUsersCount : Room -> String
roomUsersCount room =
  " [" ++ toString (List.length room.users) ++"]"
