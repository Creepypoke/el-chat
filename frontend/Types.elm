module Types exposing (..)

import Http
import RemoteData exposing (WebData)
import Navigation exposing (Location)


type alias Model =
  { rooms : WebData (List Room)
  , currentRoute : Route
  , authForm : AuthForm
  , newRoomForm : NewRoomForm
  , newMessageForm: NewMessageForm
  , jwt : Maybe JwtToken
  , jwtString : Maybe String
  , messages : List String
  , wsUrl : String
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


type alias NewMessageForm =
  { text : String }


type alias Room =
  { id : String
  , name : String
  , users : List User
  , messages : List Message
  }


type alias Message =
  { id : Maybe String
  , from : Maybe User
  , text : String
  , kind : MessageKind
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


type alias MessageToSend =
  { roomId : String
  , kind : MessageKind
  , text : Maybe String
  , jwt : Maybe String
  }


type alias ErrorMessage =
  { field: String
  , message : String
  }


type alias Flags =
  { jwt: Maybe String
  , wsUrl: String
  }

type Msg
  = LocationChanged Location
  | NewUrl String
  | RequestRooms
  | RoomsResponse (WebData (List Room))
  | JoinRoom Room
  | LeaveRoom Room (Maybe Msg)
  | UpdateAuthForm Field String
  | UpdateNewRoomForm Field String
  | UpdateNewMessageForm Field String
  | SubmitSignInForm
  | SubmitSignUpForm
  | SubmitNewRoomForm
  | SubmitNewMessageForm Room
  | SignedIn (Result Http.Error String)
  | RoomCreated (Result Http.Error Room)
  | SignOut
  | SaveToken
  | NewMessage String


type Field
  = Name
  | Password
  | PasswordConfirm
  | MessageText


type Route
  = HomeRoute
  | SignUpRoute
  | SignInRoute
  | RoomRoute String
  | NotFoundRoute


type MessageKind
  = Text
  | Join
  | Leave
  | Error