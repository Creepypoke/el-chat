module Views.Navigation exposing (navigationView)

import Html exposing (..)
import Html.Attributes exposing (href)

import Types exposing (..)
import Views.Helpers exposing (..)
import Utils exposing (..)


navigationView : Model -> Html Msg
navigationView model =
  let
    authLinks = 
      case model.jwt of
        Nothing ->
          [ li []
            [ link "/sign-in" (text "Sign In") [] ]
          , li []
            [ link "/sign-up" (text "Sign Up") [] ]
          ]
        Just jwt ->
          [ li []
            [ a [ onEventSend "click" SignOut, href "/sign-out" ] 
              [ text "Sign out"] 
            ]
          ]
    commonLinks =
      [ li []
          [ link "/" (text "Home") [] ]
      ]
  in
    div []
      [ ul []
        (List.concat [commonLinks, authLinks])
      ]


