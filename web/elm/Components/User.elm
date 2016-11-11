module Components.User exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

import Components.HtmlAttributesExtra exposing (innerHtml)

type alias Model =
  { url : String
  , name : String
  , balance : String
  , tags : List String }

empty : Model
empty =
  { url = ""
  , name = ""
  , balance = ""
  , tags = [] }

badge : Model -> Html a
badge model =
  h5 [] [ a [ href model.url, class "badge badge-primary p-0" ]
    [ span [ class "badge badge-info" ] [ text "1337" ]
    , span [ class "p-1" ] [ text model.name ] ]
    ]

view : Model -> Html a
view model =
  tr []
  [ td [ class "align-middle" ] [ input [ type' "checkbox" ] [] ]
  , td [] [ badge model ]
  , td [] (List.map
    (\tag ->
      a
      [ href ("/users?filter=tag%3A" ++ tag), class "badge badge-info mr-1" ]
      [ span [] [ text tag ] ]
    )
    model.tags
  )
  , td [ title "Next delivery" ] [ text "Tomorrow" ]
  , td [ class "text-right" ] [ strong [ innerHtml model.balance ] [] ] ]
