module Components.UserTransaction exposing (view, Model)

import Html exposing (..)
import Html.Attributes exposing (..)

import Lib.HtmlAttributesExtra exposing (innerHtml)

type alias Model =
  { creationDate : String
  , valueDate : String
  , description : String
  , amount : String
  , balance : String }

view : Model -> Html a
view model =
  tr []
  [ td [] [ text model.creationDate ]
  , td [] [ text model.valueDate ]
  , td [] [ text model.description ]
  , td [ class "text-right", innerHtml model.amount ] []
  , td [ class "text-right" ] [ text model.balance ] ]
