module Components.DeliveryListCalendar exposing (..)

import Date exposing (Date)
import Dict exposing (Dict)

import Task exposing (Task)
import Http exposing (Error)
import JsonApi exposing (Document)
import Components.JsonApiExtra exposing (get)
import Components.DeliveryListModels exposing (..)
import Components.DeliveryListDecoder as DeliveryListDecoder
import Components.DeliveryListView as DeliveryListView
import Components.Delivery as Delivery

type alias JsonModel =
  { deliveries: List Delivery.Model }

type Msg
  = Fetch Window
  | FetchSucceed Document
  | FetchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Fetch window ->
      ({ model | fetching = True, window = window }, fetchDeliveries window)
    FetchSucceed document ->
      let
        deliveries = DeliveryListDecoder.decodeDeliveries document
        days =
          List.foldr
            (\delivery -> \dict -> updateDays delivery dict)
            Dict.empty
            deliveries
          |> Dict.values
        form = DeliveryListView.calendarForm days
        calendar = { form = form }
      in
        ({ model | fetching = False
                 , calendar = calendar
                 , deliveries = deliveries } , Cmd.none)
    FetchFail error ->
      ({ model | fetching = False }, Cmd.none)

updateDays : Delivery.Model -> Dict String Day -> Dict String Day
updateDays delivery days =
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

fetchDeliveries : Window -> Cmd Msg
fetchDeliveries window =
  let
    (from, to) = window
    url = "/api/deliveries?include=user&filter[from]=" ++ from ++ "&filter[to]=" ++ to
  in
    request url

unsafeFromString : String -> Date
unsafeFromString string =
  case Date.fromString string of
      Ok date -> date
      Err msg -> Debug.crash("unsafeFromString")
