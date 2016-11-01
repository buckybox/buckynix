module App exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (class)

import Components.CustomerList as CustomerList

main : Html a
main =
  div [ class "elm-app" ] [ CustomerList.view ]
