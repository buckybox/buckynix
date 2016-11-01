module Customer exposing (view, Model)

import Html exposing (..)
import Html.Attributes exposing (class, href)

type alias Model =
  { url : String
  , name : String
  , email : String }

view : Model -> Html a
view model =
  tr []
  [ td [] [ a [ href model.url ] [ text model.name ] ]
  , td [] [ text "Next del???" ]
  , td [] [ text model.email ] ]
