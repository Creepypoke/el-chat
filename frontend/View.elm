module View exposing (view)

import Html exposing (..)
import RemoteData exposing (WebData)

import Types exposing (..)
import Views.Navigation exposing (navigationView)
import Views.Rooms exposing (roomsView)
import Views.SignUp exposing (signUpView)
import Views.SignIn exposing (signInView)
import Views.NotFound exposing (notFoundView)
import Views.Room exposing (roomView)

view : Model -> Html Msg
view model =
  div []
    [ navigationView model
    , case model.currentRoute of
        HomeRoute ->
          roomsView model
        SignUpRoute ->
          signUpView model
        SignInRoute ->
          signInView model
        RoomRoute roomId ->
          case findRoomById model.rooms roomId of
            Just room ->
              roomView model room
            Nothing ->
              notFoundView
        NotFoundRoute ->
          notFoundView
    , div []
      (List.map text model.messages)
    ]


findRoomById : WebData (List Room) -> String -> Maybe Room
findRoomById rooms roomId =
  case RemoteData.toMaybe rooms of
    Just rooms ->
      rooms
        |> List.filter (\post -> post.id == roomId)
        |> List.head
    Nothing ->
      Nothing