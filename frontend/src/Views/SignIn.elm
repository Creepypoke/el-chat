module Views.SignIn exposing (signInView)

import Html exposing (..)
import Html.Events exposing (onInput)
import Html.Attributes exposing (..)

import Types exposing (..)
import Utils exposing (..)
import Views.Helpers exposing (errors)

signInView : Model -> Html Msg
signInView model =
  div []
    [ h1 [] [ text "Sing In"]
    , Html.form
      [ onEventSend "submit" SubmitSignInForm ]
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
        [ button []
            [ text "Sing In"]
        ]
      , errors model.authForm.errors
      ]
    ]


