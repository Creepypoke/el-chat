module View exposing (view)

import Types exposing (..)
import Html exposing (..)
import Views.Navigation exposing (navigationView)
import Views.Rooms exposing (roomsView)
import Views.SignUp exposing (signUpView)
import Views.SignIn exposing (signInView)
import Views.NotFound exposing (notFoundView)

view : Model -> Html Msg
view model =
  div []
    [ navigationView model
    , case model.currentRoute of
        HomeRoute ->
          roomsView model.rooms
        SignUpRoute ->
          signUpView model
        SignInRoute ->
          signInView model
        NotFoundRoute ->
          notFoundView
    ]
