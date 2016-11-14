module Components.DeliveryListCalendar exposing (..)

import Dict exposing (Dict)

import Task exposing (Task)
import Http exposing (Error)
import JsonApi exposing (Document)

import Lib.UUID exposing (UUID)
import Lib.JsonApiExtra as JsonApiExtra

import Components.DeliveryListModels exposing (..)
import Components.DeliveryListDecoder as DeliveryListDecoder
import Components.DeliveryListView as DeliveryListView
import Components.Delivery as Delivery

type alias JsonModel =
  { deliveries: Dict UUID Delivery.Model }

type Msg
  = FetchSelectedWindow Window
  | FetchVisibleWindow Window
  | FetchSucceedSelectedWindow Document
  | FetchSucceedVisibleWindow Document
  | FetchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    FetchSelectedWindow window ->
      ( { model | fetching = True , selectedWindow = window }
      , fetchSelectedWindow window )
    FetchVisibleWindow window ->
      ( { model | fetching = True , visibleWindow = window }
      , fetchVisibleWindow window )
    FetchSucceedSelectedWindow document ->
      let
        selectedDeliveries =
          DeliveryListDecoder.decodeDeliveries document
          |> Dict.values
      in
        ({ model | fetching = False
                 , selectedDeliveries = selectedDeliveries } , Cmd.none)
    FetchSucceedVisibleWindow document ->
      let
        newDeliveries = DeliveryListDecoder.decodeDeliveries document
        allDeliveries = Dict.union model.allDeliveries newDeliveries
        form = DeliveryListView.calendarForm
          (Dict.values allDeliveries)
          model.visibleWindow
        calendar = { form = form }
      in
        ({ model | fetching = False
                 , calendar = calendar
                 , allDeliveries = allDeliveries } , Cmd.none)
    FetchFail error ->
      ({ model | fetching = False }, Cmd.none)

request : (Document -> Msg) -> String -> Cmd Msg
request succeedMsg url =
  Task.perform FetchFail succeedMsg (JsonApiExtra.get DeliveryListDecoder.decodeDocument url)

fetchSelectedWindow : Window -> Cmd Msg
fetchSelectedWindow window =
  let
    (from, to) = window
  in
    "/api/deliveries?include=user&filter[from]=" ++ from ++ "&filter[to]=" ++ to
    |> request FetchSucceedSelectedWindow

fetchVisibleWindow : Window -> Cmd Msg
fetchVisibleWindow window =
  let
    (from, to) = window
  in
    "/api/deliveries?filter[from]=" ++ from ++ "&filter[to]=" ++ to
    |> request FetchSucceedVisibleWindow
