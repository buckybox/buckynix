module Customer exposing (view, Model)

import Html exposing (..)
import Html.Attributes exposing (class, href)

import Json.Encode
import VirtualDom

innerHtml : String -> Attribute msg
innerHtml =
  VirtualDom.property "innerHTML" << Json.Encode.string

type alias Model =
  { url : String
  , name : String
  , balance : String }

view : Model -> Html a
view model =
  tr []
  [ td [] [ a [ href model.url ] [ text model.name ] ]
  , td [] [ text "Next del???" ]
  , td [] [ strong [ innerHtml model.balance ] [] ] ]
