module Views.Navigation exposing (navigationView)

import Html exposing (..)
import Html.Attributes exposing (href, class, classList)


import Types exposing (..)
import Routing exposing (extractUrl)
import Views.Helpers exposing (..)


navigationView : Maybe JwtToken -> Route -> Html Msg
navigationView jwt currentRoute =
  let
    authLinks =
      case jwt of
        Nothing ->
          [ navItem SignInRoute currentRoute "Sign In"
          , navItem SignUpRoute currentRoute "Sign Up"]
        Just jwt ->
          [ navItem SignOutRoute currentRoute "Sign Out" ]
    commonLinks =
      [ navItem HomeRoute currentRoute "Home"]
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