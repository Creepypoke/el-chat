module Views.SignUp exposing (signUpView)

import Html exposing (..)
import Html.Events exposing (onInput)
import Html.Attributes exposing (..)

import Types exposing (..)
import Utils exposing (..)
import Views.Helpers exposing (errors)


signUpView : Model -> Html Msg
signUpView model =
  div []
    [ h1 [] [ text "Sing Up"]
    , Html.form
      [ onEventSend "submit" SubmitSignUpForm ]
      [ div []
        [ label [ for "name" ]
            [ text "Name" ]
        , br [] []
        , input
            [ id "name"
            , type_ "text"
            , value model.authForm.name
            , onInput (UpdateAuthForm Name)
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
            , onInput (UpdateAuthForm Password)
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
              , onInput (UpdateAuthForm PasswordConfirm)
              ]
              []
          ]
      , div []
        [ button []
            [ text "Sing Up"]
        ]
      , errors model.authForm.errors
      ]
    ]