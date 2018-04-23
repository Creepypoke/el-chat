module Views.Navigation exposing (navigationView)

import Html exposing (..)
import Html.Attributes exposing (href, class, classList)


import Types exposing (..)
import Utils exposing (..)
import Routing exposing (extractUrl)
import Views.Helpers exposing (..)


navigationView : Model -> Html Msg
navigationView model =
  let
    authLinks =
      case model.jwt of
        Nothing ->
          [ navItem SignInRoute model.currentRoute "Sign In"
          , navItem SignUpRoute model.currentRoute "Sign Up"]
        Just jwt ->
          [ navItem SignOutRoute model.currentRoute "Sign Out" ]
    commonLinks =
      [ navItem HomeRoute model.currentRoute "Home"]
  in
    div [class "header"]
      (List.concat [commonLinks, authLinks])


navItem : Route -> Route -> String-> Html Msg
navItem route currentRoute itemText =
  let
    url = extractUrl route
  in
    if route == currentRoute then
      div [ class "item active" ]
        [ link url ( text itemText ) [] ]
    else
      div [ class "item" ]
        [ link url ( text itemText ) [] ]