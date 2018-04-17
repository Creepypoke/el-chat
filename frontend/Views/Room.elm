module Views.Room exposing (roomView)

import Html exposing (..)

import Types exposing (..)


roomView : Model -> Room -> Html Msg
roomView model room =
  div []
    [ h1 []
      [ text (room.name ++ " # " ++ room.id) ]
    , div []
        (List.map messageView room.messages)
    ]


messageView : Message -> Html Msg
messageView message =
  case message.kind of
    Text ->
      div []
        [ strong []
            [ text (fromName message.from ++ ":") ]
        , text (" " ++ message.text )
        ]
    Join ->
      div []
        [ text (" " ++ message.text ) ]
    Leave ->
      div []
        [ text (" " ++ message.text ) ]
    Error ->
      div []
        [ text (" " ++ message.text ) ]

fromName : Maybe User -> String
fromName user =
  case user of
    Just user ->
      user.name
    Nothing ->
      ""
