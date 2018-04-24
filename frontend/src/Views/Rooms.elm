module Views.Rooms exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import RemoteData exposing (WebData)

import Types exposing (..)
import Utils exposing (..)
import Views.Helpers exposing (errors)

roomsView : WebData (List Room) -> NewRoomForm -> Html Msg
roomsView rooms newRoomForm =
  div []
    [ h2 []
      [ text "Rooms" ]
    , viewRoomsOrError rooms
    , newRoomFormView newRoomForm
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
  if (List.length rooms) > 0 then
    div []
      (List.map roomView rooms)
  else
    div []
      [ text "There is no rooms, yet" ]


newRoomFormView : NewRoomForm -> Html Msg
newRoomFormView newRoomForm =
  div []
    [ h3 [] [ text "Add room"]
    , Html.form
      [ onEventSend "submit" (SubmitForm NewRoom) ]
      [ div []
        [ label [ for "name" ]
            [ text "Name" ]
        , br [] []
        , input
            [ id "name"
            , type_ "text"
            , value newRoomForm.name
            , onInput (UpdateForm NewRoom Name)
            ]
            []
        , button []
            [ text "Add"]
        ]
      , errors newRoomForm.errors
      ]
    ]


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