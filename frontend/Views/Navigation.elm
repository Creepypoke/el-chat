module Views.Navigation exposing (navigationView)

import Html exposing (..)

import Types exposing (..)
import Views.Helpers exposing (..)


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
            [ link "/sign-out" (text "Sign Out") [] ]
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


