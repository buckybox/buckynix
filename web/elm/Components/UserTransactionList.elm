module Components.UserTransactionList exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import List

import Http exposing (Error)
import Task
import Json.Decode as Json exposing ((:=))

import Components.JsonApiExtra as JsonApiExtra
import Components.UserTransaction as UserTransaction

type alias Model =
  { userTransactions: List UserTransaction.Model
  , userId: String
  , fetchAll: Bool
  , fetching: Bool }

type alias JsonModel =
  { data: List UserTransaction.Model }

type Msg
  = Fetch
  | FetchSucceed JsonModel
  | FetchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Fetch ->
      ({ model | fetching = True }, fetchUserTransactions model)
    FetchSucceed jsonModel ->
      let
        userTransactionList = jsonModel.data
      in
        ({ model |
            userTransactions = userTransactionList
          , fetching = False
        } , Cmd.none)
    FetchFail error ->
      ({ model | fetching = False }, Cmd.none)

fetchUserTransactions : Model -> Cmd Msg
fetchUserTransactions model =
  let
    url = "/api/users/" ++ model.userId ++ "/transactions"
  in
    Task.perform FetchFail FetchSucceed (JsonApiExtra.get decodeUserTransactionFetch url)

decodeUserTransactionFetch : Json.Decoder JsonModel
decodeUserTransactionFetch =
  Json.object1 JsonModel
    ("data" := Json.list decodeUserTransactionData)

decodeUserTransactionData : Json.Decoder UserTransaction.Model
decodeUserTransactionData =
  Json.object5 UserTransaction.Model
    (Json.at ["attributes", "inserted-at"] Json.string)
    (Json.at ["attributes", "value-date"] Json.string)
    (Json.at ["attributes", "description"] Json.string)
    (Json.at ["attributes", "amount"] Json.string)
    (Json.at ["attributes", "balance"] Json.string)

initialModel : String -> Model
initialModel userId =
  { userTransactions = []
  , userId = userId
  , fetchAll = False
  , fetching = False }

view : Model -> Html Msg
view model =
  div [] [ renderUserTransactions model ]

renderUserTransactions : Model -> Html Msg
renderUserTransactions model =
  let
    moreLinkWrapper =
      if model.fetchAll then
        []
      else
        [ moreLink model.fetching ]
    rows = List.map (\userTransaction -> UserTransaction.view userTransaction) model.userTransactions
  in
    div [ class "row" ]
      [ div [ class "col-xs" ]
        [ table [ class "table table-striped table-sm" ]
          [ thead [] [ tableHead ]
          , tbody [] rows
          , tfoot [] moreLinkWrapper ]
        ]
      ]

tableHead : Html Msg
tableHead =
  tr []
  [ th [] [ text "Creation Date" ]
  , th [] [ text "Value Date" ]
  , th [] [ text "Description" ]
  , th [ class "text-right" ] [ text "Amount" ]
  , th [ class "text-right" ] [ text "Balance" ] ]

addLink : Html Msg
addLink =
  tr []
  [ td [ colspan 5 ]
       [ a [ href "/users/new", class "btn btn-outline-warning btn-block" ] [ text "Add" ] ]
  ]

moreLink : Bool -> Html Msg
moreLink fetching =
  let tag =
    if fetching then
      i [ class "fa fa-spinner fa-pulse fa-3x fa-fw" ] []
    else
      a [ href "javascript:void(0)", onClick Fetch ] [ text "show all" ]
  in
    tr []
    [ td [ colspan 5, class "text-center" ] [ tag ] ]
