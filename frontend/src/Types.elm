module Types exposing (..)

import Http
import RemoteData exposing (WebData)
import Navigation exposing (Location)


type alias Model =
  { rooms : WebData (List Room)
  , currentRoom: WebData Room
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
  { text : String
  , showEmojiWidget : Bool
  , suggestions : List String
  }


type alias Room =
  { id : String
  , name : String
  , users : List User
  , messages : List Message
  }


type alias Message =
  { id : Maybe String
  , datetime: String
  , from : User
  , text : String
  , kind : MessageKind
  , users : Maybe (List User)
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
  | RequestRoom String
  | RequestRooms
  | RoomResponse (WebData Room)
  | RoomsResponse (WebData (List Room))
  | JoinRoom Room
  | RequestRecentMessages Room
  | LeaveRoom Room (Maybe Msg)
  | UpdateForm Form Field String
  | SubmitForm Form
  | SignedIn (Result Http.Error String)
  | RoomCreated (Result Http.Error Room)
  | SignOut
  | SaveToken
  | NewWsMessage String
  | ToggleEmojiWidget Bool


type Form
  = SignIn
  | SignUp
  | NewMessage
  | NewRoom
  | Auth


type Field
  = Name
  | Password
  | PasswordConfirm
  | MessageText
  | Emoji
  | Mention


type Route
  = HomeRoute
  | SignUpRoute
  | SignInRoute
  | SignOutRoute
  | RoomRoute String
  | NotFoundRoute


type MessageKind
  = Text
  | Join
  | Leave
  | Error
  | Recent
  | Users