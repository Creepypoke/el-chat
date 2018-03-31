module Types exposing (..)

import RemoteData exposing (WebData)
import Navigation exposing (Location)


type alias Model =
  { user : User
  , rooms : WebData (List Room)
  , currentRoute : Route
  , auth : Auth
  }


type alias Auth =
  { name : String
  , password : String
  , passwordConfirm : String
  , authenticated : Bool
  }


type alias Room =
  { id : String
  , name : String
  , users : List User
  }


type alias Message =
  { id : String
  , from : User
  , text : String
  }


type alias User =
  { name : String }


type Msg
  = LocationChanged Location
  | NewUrl String
  | RequestRooms
  | RoomsResponse (WebData (List Room))
  | JoinRoom Room
  | UpdateName String
  | UpdatePassword String
  | UpdatePasswordConfirm String


type Route
  = HomeRoute
  | SignUpRoute
  | SignInRoute
  | RoomRoute String
  | NotFoundRoute