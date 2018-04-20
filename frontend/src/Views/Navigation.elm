module Views.Navigation exposing (navigationView)

import Html exposing (..)
import Html.Attributes exposing (href, class)

import Types exposing (..)
import Views.Helpers exposing (..)
import Utils exposing (..)


navigationView : Model -> Html Msg
navigationView model =
  let
    authLinks =
      case model.jwt of
        Nothing ->
          [ div [ class "item" ]
            [ link "/sign-in" (text "Sign In") [] ]
          , div [ class "item" ]
            [ link "/sign-up" (text "Sign Up") [] ]
          ]
        Just jwt ->
          [ div [ class "item" ]
            [ a [ onEventSend "click" SignOut, href "/sign-out" ]
              [ text "Sign out"]
            ]
          ]
    commonLinks =
      [ div [ class "item" ]
          [ link "/" (text "Home") [] ]
      ]
  in
    div [class "header"]
      (List.concat [commonLinks, authLinks])


