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
  , nextCount: Int
  , fetching: Bool }

type Msg
  = Fetch
  | FetchSucceed (List Customer.Model)
  | FetchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Fetch ->
      ({ model | fetching = True }, fetchCustomers model)
    FetchSucceed customerList ->
      ({
          customers = customerList
        , nextCount = model.nextCount * growthFactor
        , fetching = False
      } , Cmd.none)
    FetchFail error ->
      ({ model | fetching = False }, Cmd.none)

init : Cmd Msg
init =
  snd (update Fetch initialModel)

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
  { customers = [], nextCount = initialCount, fetching = True }

view : Model -> Html Msg
view model =
  div [ class "customer-list" ] [ renderCustomers model ]

renderCustomers model =
  let
    length = List.length(model.customers)
    more =
      if length == 0 || length == model.nextCount // growthFactor then
        [ moreLink model.fetching ]
      else
        [ ]
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

moreLink fetching =
  let tag =
    if fetching then
      i [ class "fa fa-spinner fa-pulse fa-3x fa-fw" ] []
    else
      a [ href "javascript:void(0)", onClick Fetch ] [ text "more" ]
  in
    tr []
    [ td [ colspan 4, class "text-center" ] [ tag ] ]
