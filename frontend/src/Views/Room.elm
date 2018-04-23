module Views.Room exposing (roomView)

import Debug
import RemoteData
import Http
import Html exposing (..)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (..)

import Types exposing (..)
import Utils exposing (..)


roomView : Model -> Html Msg
roomView model =
  case model.currentRoom of
    RemoteData.Success room ->
      div []
        [ h1 []
          [ text (room.name ++ " # " ++ room.id) ]
        , div [class "messages-log"]
            (List.map messageView (List.reverse room.messages))
        , messageForm model room
        ]
    RemoteData.Loading ->
      div []
        [ text "loading ..."]
    RemoteData.Failure err ->
      case err of
        Http.BadStatus res ->
          div []
            [ strong []
                [ text (toString res.status.code) ]
            , text (" " ++ res.status.message)
            ]
        _ ->
          div [] []
    _ ->
      div [] []


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
    _ ->
      div []
        []


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
      [ onEventSend "submit" (SubmitForm NewMessage)]
      [ div []
        [ input
            [ id "message"
            , type_ "text"
            , value model.newMessageForm.text
            , onInput (UpdateForm NewMessage MessageText)
            ]
            []
        , button []
            [ text "Send"]
        ]
      ]
    , div
        [ class "emoji-icon"
        , onClick (ToggleEmojiWidget (not model.newMessageForm.showEmojiWidget ))
        ]
        []
    , div
        [ class "emoji-widget"]
        (case Debug.log "err" model.newMessageForm.showEmojiWidget of
          True ->
            [ emojiWidget ]
          False ->
            []
        )
    ]


emojiWidget : Html Msg
emojiWidget =
  div []
    [ emoji "😀"
    , emoji "😁"
    , emoji "😂"
    , emoji "🤣"
    , emoji "😃"
    , emoji "😄"
    , emoji "😅"
    , emoji "😆"
    , emoji "😉"
    , emoji "😊"
    , emoji "😋"
    , emoji "😎"
    , emoji "😍"
    ]


emoji : String -> Html Msg
emoji emojiString =
  span
    [ class "emoji"
    , onClick (UpdateForm NewMessage Emoji emojiString)
    ]
    [ text emojiString ]