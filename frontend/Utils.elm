module Utils exposing (..)

import Json.Decode as Json
import Html exposing (Attribute)
import RemoteData exposing (WebData)
import Html.Events exposing (onWithOptions)

import Types exposing (..)


onClickNewUrl : String -> Attribute Msg
onClickNewUrl url =
  onWithOptions
    "click"
    { stopPropagation = True
    , preventDefault = True
    }
    (Json.succeed (NewUrl url))


onEventSend : String -> Msg -> Attribute Msg
onEventSend event msg =
  onWithOptions
    event
    { stopPropagation = True
    , preventDefault = True
    }
    (Json.succeed msg)


-- Author @kana_sama
updateAt : number -> (a -> a) -> List a -> List a
updateAt n f list =
    case ( n, list ) of
        ( _, [] ) ->
            []

        ( 0, x :: xs ) ->
            f x :: xs

        ( n, x :: xs ) ->
            x :: updateAt (n - 1) f xs


findRoomById : WebData (List Room) -> String -> Maybe Room
findRoomById rooms roomId =
  case RemoteData.toMaybe rooms of
    Just rooms ->
      rooms
        |> List.filter (\room -> room.id == roomId)
        |> List.head
    Nothing ->
      Nothing