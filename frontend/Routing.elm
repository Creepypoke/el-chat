module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)
import Types exposing (..)


extractRoute : Location -> Route
extractRoute location =
  case (parsePath matchRoute location) of
    Just route ->
      route
    Nothing ->
      NotFoundRoute


matchRoute : Parser (Route -> a) a
matchRoute =
  oneOf
    [ map HomeRoute top
    , map SignUpRoute (s "sign-up")
    , map SignInRoute (s "sign-in")
    ]