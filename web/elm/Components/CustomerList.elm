module Components.CustomerList exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List

import Http
import Task
import Json.Decode as Json exposing ((:=))
import Debug

import Customer

type alias Model =
  { customers: List Customer.Model }

type Msg
  = NoOp
  | Fetch
  | FetchSucceed (List Customer.Model)
  | FetchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)
    Fetch ->
      (model, fetchCustomers)
    FetchSucceed customerList ->
      (Model customerList, Cmd.none)
    FetchFail error ->
      case error of
        Http.UnexpectedPayload errorMessage ->
          Debug.log errorMessage
          (model, Cmd.none)
        _ ->
          (model, Cmd.none)

jsonApiGet decoder url =
  let
    request =
      Http.send Http.defaultSettings
        { verb = "GET"
        , headers = [("Accept", "application/vnd.api+json")]
        , url = url
        , body = Http.empty
        }
  in
    Http.fromJson decoder request

fetchCustomers : Cmd Msg
fetchCustomers =
  let
    url = "/api/customers"
  in
    Task.perform FetchFail FetchSucceed (jsonApiGet decodeCustomerFetch url)

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

initialModel : Model
initialModel =
  { customers = [] }

view : Model -> Html Msg
view model =
  div [ class "customer-list" ] [ renderCustomers model ]

renderCustomers model =
  table [ class "table" ]
    (List.concat [
      [ newLink ],
      (List.map renderCustomer model.customers),
      [ moreLink ]
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

renderCustomer : Customer.Model -> Html a
renderCustomer customer =
  Customer.view customer