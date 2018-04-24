module Views.SignUp exposing (signUpView)

import Html exposing (..)
import Html.Events exposing (onInput)
import Html.Attributes exposing (..)

import Types exposing (..)
import Utils exposing (..)
import Views.Helpers exposing (errors)


signUpView : AuthForm -> Html Msg
signUpView authForm =
  div []
    [ h1 [] [ text "Sing Up"]
    , Html.form
      [ onEventSend "submit" (SubmitForm SignUp) ]
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
          [ label [ for "password-confirm" ]
              [ text "Password Confirm" ]
          , br [] []
          , input
              [ id "password-confirm"
              , type_ "password"
              , onInput (UpdateForm Auth PasswordConfirm)
              ]
              []
          ]
      , div []
        [ button []
            [ text "Sing Up"]
        ]
      , errors authForm.errors
      ]
    ]