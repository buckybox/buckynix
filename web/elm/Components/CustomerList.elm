module Components.CustomerList exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import List

import Http exposing (Error)
import Task
import Json.Decode as Json exposing ((:=))

import Components.JsonApi as JsonApi
import Components.Customer as Customer

type alias Model =
  { customers: List Customer.Model
  , filter: String
  , nextCount: Int
  , fetching: Bool
  , filterCount: Int
  , totalCount: Int }

type alias JsonModel =
  { data: List Customer.Model
  , filterCount: Int
  , totalCount: Int }

type Msg
  = Fetch
  | FetchSucceed JsonModel
  | FetchFail Http.Error
  | Search String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Fetch ->
      ({ model | fetching = True }, fetchCustomers model)
    FetchSucceed jsonModel ->
      let
        customerList = jsonModel.data
        factor = if model.nextCount > List.length(customerList) then
          1 -- don't grow if no more customers
        else
          growthFactor
      in
        ({ model |
            customers = customerList
          , nextCount = model.nextCount * factor
          , fetching = False
          , filterCount = jsonModel.filterCount
          , totalCount = jsonModel.totalCount
        } , Cmd.none)
    FetchFail error ->
      ({ model | fetching = False }, Cmd.none)
    Search filter ->
      let updatedModel = { model | filter = filter }
      in (updatedModel, fetchCustomers updatedModel)

fetchCustomers : Model -> Cmd Msg
fetchCustomers model =
  let
    url = "/api/customers?count=" ++ (toString model.nextCount)
      ++ "&filter=" ++ model.filter
  in
    Task.perform FetchFail FetchSucceed (JsonApi.get decodeCustomerFetch url)

decodeCustomerFetch : Json.Decoder JsonModel
decodeCustomerFetch =
  Json.object3 JsonModel
    ("data" := Json.list decodeCustomerData)
    (Json.at ["meta", "filter-count"] Json.int)
    (Json.at ["meta", "total-count"] Json.int)

decodeCustomerData : Json.Decoder Customer.Model
decodeCustomerData =
  Json.object4 Customer.Model
    (Json.at ["attributes", "url"] Json.string)
    (Json.at ["attributes", "name"] Json.string)
    (Json.at ["attributes", "balance"] Json.string)
    (Json.at ["attributes", "tags"] (Json.list Json.string))

initialCount = 25
growthFactor = 2 -- we'll fetch X times as many on each fetch (exponential)

initialModel : Model
initialModel =
  { customers = []
  , filter = ""
  , nextCount = initialCount
  , fetching = True
  , filterCount = 0
  , totalCount = 0 }

view : Model -> Html Msg
view model =
  div [ class "customer-list" ]
    [ searchBar model
    , renderCustomers model ]

renderCustomers model =
  let
    length = List.length(model.customers)
    moreLinkWrapper =
      if length == 0 || length == model.nextCount // growthFactor then -- FIXME
        [ moreLink model.fetching ]
      else
        []
    rows = List.map (\customer -> Customer.view customer) model.customers
  in
    div [ class "row mt-3" ]
      [ div [ class "col-xs" ]
        [ table [ class "table table-striped table-sm" ]
          [ thead [] [ newLink ]
          , tbody [] rows
          , tfoot [] moreLinkWrapper ]
        ]
      ]

searchBar model =
  div [ class "row flex-items-xs-middle" ]
    [ div [ class "col-xs-3" ] []
    , div [ class "col-xs-6" ]
      [ input [ name "filter", placeholder "Search customers", class "search form-control", onInput Search, value model.filter ] [] ]
    , div [ class "col-xs-3" ]
      [ small [ class "text-muted" ] [ text (
        (toString model.filterCount) ++ " of " ++
        (toString model.totalCount) ++ " matches" )
      ] ]
    ]

newLink =
  tr []
  [ td [ colspan 4 ]
       [ a [ href "/customers/new", class "btn btn-outline-warning btn-block" ] [ text "Create a new customer" ] ]
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
