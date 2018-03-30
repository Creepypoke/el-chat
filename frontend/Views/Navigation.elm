module Views.Navigation exposing (navigationView)

import Html exposing (..)
import Html.Attributes exposing (href)

import Types exposing (..)
import Utils exposing (onClickNewUrl)


navigationView : Model -> Html Msg
navigationView model =
  div []
    [ ul [] 
      [ li []
        [  a [ onClickNewUrl "/sign-in", href "/sign-in" ]
            [ text "Sign In" ] 
        ]
      , li []
        [  a [ onClickNewUrl "/sign-up", href "/sign-up" ]
            [ text "Sign Up" ] 
        ]
      , li []
        [  a [onClickNewUrl "/", href "/" ]
            [ text "Home" ] 
        ]
      ]
    ]