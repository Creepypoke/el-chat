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
  div []
    [ strong []
        [ text (message.from.name ++ ":") ]
    , text (" " ++ message.text )
    ]
