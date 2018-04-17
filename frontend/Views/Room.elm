module Views.Room exposing (roomView)

import Html exposing (..)
import Html.Events exposing (onInput)
import Html.Attributes exposing (..)



import Types exposing (..)
import Utils exposing (..)

roomView : Model -> Room -> Html Msg
roomView model room =
  div []
    [ h1 []
      [ text (room.name ++ " # " ++ room.id) ]
    , div []
        (List.map messageView room.messages)
    , messageForm model room
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


messageForm : Model -> Room -> Html Msg
messageForm model room =
  div []
    [ Html.form
      [ onEventSend "submit" (SubmitNewMessageForm room)]
      [ div []
        [ input
            [ id "message"
            , type_ "text"
            , value model.newMessageForm.text
            , onInput (UpdateNewMessageForm MessageText)
            ]
            []
        , button []
            [ text "Send"]
        ]
      ]
    ]