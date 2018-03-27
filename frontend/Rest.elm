module Rest exposing (..)

import Types exposing (..)
import Http
import Json.Decode exposing (int, string, Decoder, list)
import Json.Decode.Pipeline exposing (decode, required)
import RemoteData


getRooms : Cmd Msg
getRooms =
  list roomDecoder 
    |> Http.get "/news"
    |> RemoteData.sendRequest
    |> Cmd.map RoomsResponse


roomDecoder : Decoder Room
roomDecoder =
  decode Room
    |> required "id" string
    |> required "name" string
    |> required "users" (list userDecoder)


userDecoder : Decoder User
userDecoder =
  decode User
    |> required "name" string