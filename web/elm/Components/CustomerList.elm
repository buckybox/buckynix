module Components.CustomerList exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)

view : Html a
view =
  table [ class "table" ] [
    tr [] [
      td [] [ text "C1" ]
    ],
    tr [] [
      td [] [ text "C2" ]
    ]
  ]
