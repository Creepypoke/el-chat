module Types exposing (..)

import Navigation exposing (Location)


type alias Model =  
  { name : String
  }


type alias Room = 
  { name : String
  , users : List User 
  , id : String
  }


type alias User =
  { name : String }


type Msg 
  = LocationChanged Location


type Route 
  = HomeRoute
  
