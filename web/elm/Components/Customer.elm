module Components.Customer exposing (view, Model)

import Html exposing (..)
import Html.Attributes exposing (class, href, title)

import Components.HtmlAttributesExtra exposing (innerHtml)

type alias Model =
  { url : String
  , name : String
  , balance : String
  , tags : List String }

view : Model -> Html a
view model =
  tr []
  [ td [] [ a [ href model.url ] [ text model.name ] ]
  , td [] (List.map (\tag -> a [ href ("/customers?query=tag:" ++ tag), class "badge badge-info mr-1" ] [ text tag ]) model.tags)
  , td [ title "Next delivery" ] [ text "Tomorrow" ]
  , td [ class "text-right" ] [ strong [ innerHtml model.balance ] [] ] ]
