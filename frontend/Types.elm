module Types exposing (..)

import Http
import RemoteData exposing (WebData)
import Navigation exposing (Location)


type alias Model =
  { user : User
  , rooms : WebData (List Room)
  , currentRoute : Route
  , authForm : AuthForm
  , jwt : Maybe JwtToken
  , jwtString : Maybe String
  , messages : List String
  }


type alias AuthForm =
  { name : String
  , password : String
  , passwordConfirm : String
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


type alias JwtToken =
  { name : String
  , iat: Int
  }


type Msg
  = LocationChanged Location
  | NewUrl String
  | RequestRooms
  | RoomsResponse (WebData (List Room))
  | JoinRoom Room
  | UpdateName String
  | UpdatePassword String
  | UpdatePasswordConfirm String
  | SubmitSignInForm
  | SubmitSignUpForm
  | SignedIn (Result Http.Error String)
  | SaveToken


type Route
  = HomeRoute
  | SignUpRoute
  | SignInRoute
  | RoomRoute String
  | NotFoundRoute