module Views.SignIn exposing (signInView)

import Html exposing (..)
import Html.Events exposing (onInput)
import Html.Attributes exposing (..)

import Types exposing (..)
import Utils exposing (..)
import Views.Helpers exposing (errors)

signInView : AuthForm -> Html Msg
signInView authForm =
  div []
    [ h1 [] [ text "Sing In"]
    , Html.form
      [ onEventSend "submit" (SubmitForm SignIn) ]
      [ div []
        [ label [ for "name" ]
            [ text "Name" ]
        , br [] []
        , input
            [ id "name"
            , type_ "text"
            , value authForm.name
            , onInput (UpdateForm Auth Name)
            ]
            []
        ]
      , div []
        [ label [ for "password" ]
            [ text "Password" ]
        , br [] []
        , input
            [ id "password"
            , type_ "password"
            , onInput (UpdateForm Auth Password)
            ]
            []
        ]
      , div []
        [ button []
            [ text "Sing In"]
        ]
      , errors authForm.errors
      ]
    ]


