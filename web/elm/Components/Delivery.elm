module Components.Delivery exposing (view, Model)

import Html exposing (..)
import Html.Attributes exposing (..)

import Components.User as User

type alias Model =
  { date : String
  -- , user : User.Model
  , address : String
  , product : String }

view : Model -> Html a
view model =
  tr []
  -- [ td [] [ User.badge model.user ]
  [ td [] [ text model.address ]
  , td [] [ text model.product ] ]
