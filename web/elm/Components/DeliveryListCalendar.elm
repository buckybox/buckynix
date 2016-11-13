module Components.DeliveryListCalendar exposing (..)

import Date exposing (Date)
import Dict exposing (Dict)

import Task exposing (Task)
import Http exposing (Error)
import JsonApi exposing (Document)

import Lib.UUID exposing (UUID)

import Components.JsonApiExtra exposing (get)
import Components.DeliveryListModels exposing (..)
import Components.DeliveryListDecoder as DeliveryListDecoder
import Components.DeliveryListView as DeliveryListView
import Components.Delivery as Delivery

type alias JsonModel =
  { deliveries: Dict UUID Delivery.Model }

type Msg
  = FetchSelectedWindow Window
  | FetchVisibleWindow Window
  | FetchSucceed Document
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
    FetchSucceed document ->
      let
        newDeliveries = DeliveryListDecoder.decodeDeliveries document
        allDeliveries = Dict.union newDeliveries model.allDeliveries
        selectedDeliveries = Dict.filter
          (\key -> \delivery -> selectedDay delivery model.selectedWindow)
          allDeliveries

        days =
          List.foldr
            (\delivery -> \dict -> buildDays delivery dict)
            (Dict.empty)
            (Dict.values allDeliveries)

        form = DeliveryListView.calendarForm (Dict.values days)
        calendar = { form = form }
      in
        ({ model | fetching = False
                 , calendar = calendar
                 , selectedDeliveries = selectedDeliveries
                 , allDeliveries = allDeliveries } , Cmd.none)
    FetchFail error ->
      ({ model | fetching = False }, Cmd.none)

selectedDay : Delivery.Model -> Window -> Bool
selectedDay delivery window =
  delivery.date >= fst window && delivery.date <= snd window

buildDays : Delivery.Model -> Dict String Day -> Dict String Day
buildDays delivery days =
  let
    date = delivery.date
  in
    case Dict.get date days of
      Just day ->
        Dict.insert date
          { day | deliveryCount = day.deliveryCount + 1 }
          days
      Nothing ->
        Dict.insert date
          { date = unsafeFromString date
          , state = Pending
          , deliveryCount = 1 }
          days

request : String -> Cmd Msg
request url =
  Task.perform FetchFail FetchSucceed (get DeliveryListDecoder.decodeDocument url)

fetchSelectedWindow : Window -> Cmd Msg
fetchSelectedWindow window =
  let
    (from, to) = window
  in
    "/api/deliveries?include=user&filter[from]=" ++ from ++ "&filter[to]=" ++ to |> request

fetchVisibleWindow : Window -> Cmd Msg
fetchVisibleWindow window =
  let
    (from, to) = window
  in
    "/api/deliveries?filter[from]=" ++ from ++ "&filter[to]=" ++ to |> request

unsafeFromString : String -> Date
unsafeFromString string =
  case Date.fromString string of
      Ok date -> date
      Err msg -> Debug.crash("unsafeFromString")
