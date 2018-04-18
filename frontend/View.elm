module View exposing (view)

import Html exposing (..)
import RemoteData exposing (WebData)

import Types exposing (..)
import Utils exposing (..)
import Views.Room exposing (roomView)
import Views.Rooms exposing (roomsView)
import Views.SignUp exposing (signUpView)
import Views.SignIn exposing (signInView)
import Views.NotFound exposing (notFoundView)
import Views.Navigation exposing (navigationView)

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
          roomView model
        NotFoundRoute ->
          notFoundView
    , div []
      (List.map text model.messages)
    ]