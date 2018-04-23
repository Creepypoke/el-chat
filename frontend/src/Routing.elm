module Routing exposing (..)

import UrlParser exposing (..)
import Navigation exposing (Location)

import Types exposing (..)


extractRoute : Location -> Route
extractRoute location =
  case (parsePath matchRoute location) of
    Just route ->
      route
    Nothing ->
      NotFoundRoute


extractUrl : Route -> String
extractUrl route =
  case route of
    HomeRoute ->
      "/"
    SignUpRoute ->
      "/sign-up"
    SignInRoute ->
      "/sign-in"
    RoomRoute roomId ->
      "/rooms/" ++ roomId
    SignOutRoute ->
      "/sign-out"
    NotFoundRoute ->
      "/"

matchRoute : Parser (Route -> a) a
matchRoute =
  oneOf
    [ map HomeRoute top
    , map SignUpRoute (s "sign-up")
    , map SignInRoute (s "sign-in")
    , map RoomRoute (s "rooms" </> string)
    , map SignOutRoute (s "sign-out")
    ]
