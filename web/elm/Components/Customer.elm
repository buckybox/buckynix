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
  , balance : String
  , tags : List String }

view : Model -> Html a
view model =
  tr []
  [ td [] [ a [ href model.url ] [ text model.name ] ]
  , td [] (List.map (\tag -> a [ href ("/customers/tag/" ++ tag), class "badge badge-info mr-1" ] [ text tag ]) model.tags)
  , td [] [ text "Next del???" ]
  , td [ class "text-right" ] [ strong [ innerHtml model.balance ] [] ] ]
