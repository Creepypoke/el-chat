module Views.Room exposing (roomView)

import Debug
import RemoteData
import Http
import Html exposing (..)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (..)
import RemoteData exposing (WebData)

import Types exposing (..)
import Utils exposing (..)


roomView : WebData Room -> NewMessageForm -> Html Msg
roomView currentRoom newMessageForm =
  case currentRoom of
    RemoteData.Success room ->
      div [ class "chat-window" ]
        [ h1 []
          [ text room.name ]
        , div [ class "messages-log" ]
            (List.map messageView room.messages)
        , messageForm newMessageForm room
        ]
    RemoteData.Loading ->
      div []
        [ text "loading ..." ]
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
            [ text (message.from.name ++ ":") ]
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


messageForm : NewMessageForm -> Room -> Html Msg
messageForm newMessageForm room =
  div []
    [ Html.form
      [ onEventSend "submit" (SubmitForm NewMessage)]
      [ div []
        [ input
            [ id "message"
            , type_ "text"
            , value newMessageForm.text
            , onInput (UpdateForm NewMessage MessageText)
            ]
            []
        , button []
            [ text "Send"]
        ]
      ]
    , if List.length newMessageForm.suggestions > 0 then
        mentionSuggestions newMessageForm.suggestions
      else
        text ""
    , div
        [ class "emoji-icon"
        , onClick (ToggleEmojiWidget (not newMessageForm.showEmojiWidget ))
        ]
        []
    , div
        [ class "emoji-widget"]
        (case newMessageForm.showEmojiWidget of
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


userInList : String -> Html Msg
userInList userName =
  li
    [ onClick (UpdateForm NewMessage Mention userName)]
    [ text userName]


mentionSuggestions : List String -> Html Msg
mentionSuggestions suggestions =
  ul
    [ class "mention-suggest"]
    (List.map userInList suggestions)