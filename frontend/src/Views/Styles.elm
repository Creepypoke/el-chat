module Views.Styles exposing (..)

import Style exposing (..)


type Styles
  = None
  | Main
  | CursorPointer



stylesheet =
  Style.styleSheet
    [ style CursorPointer
        [ cursor "pointer" ]
    ]