module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)

import Types exposing (..)
import Views.Room exposing (roomView)
import Views.Rooms exposing (roomsView)
import Views.SignUp exposing (signUpView)
import Views.SignIn exposing (signInView)
import Views.NotFound exposing (notFoundView)
import Views.Navigation exposing (navigationView)

view : Model -> Html Msg
view model =
  div []
    [ navigationView model.jwt model.currentRoute
    , div [class "content"]
      [ case model.currentRoute of
          HomeRoute ->
            roomsView model.rooms model.newRoomForm
          SignUpRoute ->
            signUpView model.authForm
          SignInRoute ->
            signInView model.authForm
          RoomRoute roomId ->
            roomView model.currentRoom model.newMessageForm
          NotFoundRoute ->
            notFoundView
          SignOutRoute ->
            roomsView model.rooms model.newRoomForm
      ]
    , div []
      (List.map text model.messages)
    ]