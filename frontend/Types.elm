module Types exposing (..)

import Http
import RemoteData exposing (WebData)
import Navigation exposing (Location)


type alias Model =
  { rooms : WebData (List Room)
  , currentRoute : Route
  , authForm : AuthForm
  , newRoomForm : NewRoomForm
  , jwt : Maybe JwtToken
  , jwtString : Maybe String
  , messages : List String
  }


type alias AuthForm =
  { name : String
  , password : String
  , passwordConfirm : String
  , errors : List ErrorMessage
  }


type alias NewRoomForm =
  { name : String
  , errors : List ErrorMessage
  }

type alias Room =
  { id : String
  , name : String
  , users : List User
  , messages : List Message
  }


type alias Message =
  { id : String
  , from : User
  , text : String
  , kind : String
  }


type alias User =
  { name : String
  , id : String
  }


type alias JwtToken =
  { name : String
  , id : String
  , iat : Int
  }


type alias WsMessage =
  { roomId : String
  , message : Maybe Message
  , messages : Maybe (List Message)
  }


type alias ErrorMessage =
  { field: String
  , message : String
  }


type Msg
  = LocationChanged Location
  | NewUrl String
  | RequestRooms
  | RoomsResponse (WebData (List Room))
  | JoinRoom Room
  | UpdateAuthForm Field String
  | UpdateNewRoomForm Field String
  | SubmitSignInForm
  | SubmitSignUpForm
  | SubmitNewRoomForm
  | SignedIn (Result Http.Error String)
  | RoomCreated (Result Http.Error Room)
  | SignOut
  | SaveToken
  | NewMessage String


type Field
  = Name
  | Password
  | PasswordConfirm


type Route
  = HomeRoute
  | SignUpRoute
  | SignInRoute
  | RoomRoute String
  | NotFoundRoute