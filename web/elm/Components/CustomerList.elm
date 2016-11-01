module Components.CustomerList exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import List
import Customer

type alias Model =
  { customers: List Customer.Model }

type Msg
  = NoOp
  | Fetch

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)
    Fetch ->
      (customers, Cmd.none)

initialModel : Model
initialModel =
  { customers = [] }

customers : Model
customers =
  { customers =
    [ { url = "yo", name = "Joe", email = "joe@e.net" }
    , { url = "yo", name = "Bob", email = "bob@e.net" } ]
  }

view : Model -> Html Msg
view model =
  div [ class "article-list" ]
  [ table [ class "table" ] (List.map renderCustomer model.customers)
  , button [ onClick Fetch, class "btn btn-primary" ] [ text "Fetch" ] ]

renderCustomer : Customer.Model -> Html a
renderCustomer customer =
  Customer.view customer
