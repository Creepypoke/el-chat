module Types exposing (..)

import RemoteData exposing (WebData)
import Navigation exposing (Location)


type alias Model =  
  { name : String
  , rooms : WebData (List Room)
  }


type alias Room = 
  { id : String
  , name : String
  , users : List User 
  }


type alias User =
  { name : String }


type Msg 
  = LocationChanged Location
  | RoomsResponse (WebData (List Room))


type Route 
  = HomeRoute
  
