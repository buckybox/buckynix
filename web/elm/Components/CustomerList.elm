module Components.CustomerList exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List

import Http exposing (Error)
import Task
import Json.Decode as Json exposing ((:=))

import Components.JsonApi as JsonApi
import Components.Customer as Customer

type alias Model =
  { customers: List Customer.Model
  , nextCount: Int }

type Msg
  = Fetch
  | FetchSucceed (List Customer.Model)
  | FetchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Fetch ->
      (model, fetchCustomers model)
    FetchSucceed customerList ->
      ({
          customers = customerList
        , nextCount = model.nextCount * growthFactor
      } , Cmd.none)
    FetchFail error ->
      (model, Cmd.none)

fetchCustomers : Model -> Cmd Msg
fetchCustomers model =
  let
    url = "/api/customers?count=" ++ (toString model.nextCount)
  in
    Task.perform FetchFail FetchSucceed (JsonApi.get decodeCustomerFetch url)

decodeCustomerFetch : Json.Decoder (List Customer.Model)
decodeCustomerFetch =
  Json.object1 identity
    ("data" := Json.list decodeCustomerData)

decodeCustomerData : Json.Decoder Customer.Model
decodeCustomerData =
  Json.object4 Customer.Model
    (Json.at ["attributes", "url"] Json.string)
    (Json.at ["attributes", "name"] Json.string)
    (Json.at ["attributes", "balance"] Json.string)
    (Json.at ["attributes", "tags"] (Json.list Json.string))

initialCount = 5
growthFactor = 2 -- we'll fetch X times as many on each fetch (exponential)

initialModel : Model
initialModel =
  { customers = [], nextCount = initialCount }

view : Model -> Html Msg
view model =
  div [ class "customer-list" ] [ renderCustomers model ]

renderCustomers model =
  let more =
    if List.length(model.customers) < model.nextCount // growthFactor then
      [ ]
    else
      [ moreLink ]
  in
    table [ class "table" ]
      (List.concat [
        [ newLink ],
        (List.map (\customer -> Customer.view customer) model.customers),
        more
      ])

newLink =
  tr [ class "new-row" ]
  [ td [ colspan 4 ]
       [ a [ href "/customers/new", class "btn btn-primary" ] [ text "Create a new customer" ] ]
  ]

moreLink =
  tr []
  [ td [ colspan 4, class "text-center" ]
       [ a [ href "javascript:void(0)", onClick Fetch ] [ text "more" ] ]
  ]
