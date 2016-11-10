module Components.DeliveryListCalendar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

import Http exposing (Error)
import Task
import Json.Decode as Json exposing ((:=))

import Collage exposing (Form)
import Text
import String
import Dict exposing (Dict)
import Color exposing (Color)
import Element exposing (Element)
import Date exposing (Date)

import Components.JsonApi as JsonApi
import Components.Delivery as Delivery

type DayState = Delivered | Pending | Open

dayStateColor : DayState -> Color
dayStateColor state =
  case state of
    Delivered -> Color.rgb 204 204 204
    Pending   -> Color.rgb 255 220 90
    Open      -> Color.rgb 0 168 23

type alias Day =
  { date: Date
  , state: DayState
  , deliveryCount: Int }

type alias Window = (String, String)

type alias Calendar =
  { days: List Day
  , form: Form }

type alias Model =
  { calendar: Calendar
  , window: Window
  , fetching: Bool }

initialModel : Model
initialModel =
  { calendar =
    { days = []
    , form = Text.fromString "..." |> Collage.text }
  , window = ("2016-11-11", "2016-11-11")
  , fetching = False }

type alias JsonModel =
  { deliveries: List Delivery.Model }

renderCalendarForm : List Day -> Form
renderCalendarForm days =
  let
    width = 30 + 1 -- add 1 px for border
    xPositions = List.map (\x -> toFloat(x) * width) [1..(List.length days)]
  in
    List.map2 (\day -> \x -> renderDay day |> Collage.moveX x) days xPositions
    |> Collage.group

renderDay : Day -> Form
renderDay day =
  let
    height = 100
    width = 30
    fontHeight = 10

    count = toString day.deliveryCount
    dow = toString (Date.dayOfWeek day.date) |> String.left 1
  in
    Collage.group
    [
      Text.fromString count
      |> Collage.text
      |> Collage.moveY (height / 2 + fontHeight)
    ,
      Collage.rect width height
      |> Collage.filled (dayStateColor day.state)
    ,
      Text.fromString dow
      |> Collage.text
      |> Collage.moveY (-height / 2 + fontHeight)
    ,
      Text.fromString (toString (Date.day day.date))
      |> Text.color Color.gray
      |> Collage.text
      |> Collage.moveY (-height / 2 - fontHeight)
    ]

type Msg
  = Fetch Window
  | FetchSucceed JsonModel
  | FetchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Fetch window ->
      ({ model | fetching = True, window = window }, fetchDeliveries model)
    FetchSucceed jsonModel ->
      let
        deliveries = jsonModel.deliveries
        days = List.foldr (\delivery -> \dict -> updateDays delivery dict) Dict.empty deliveries |> Dict.values
        form = renderCalendarForm days
        calendar = { days = days, form = form }
      in
        ({ model | fetching = False, calendar = calendar} , Cmd.none)
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

unsafeFromString : String -> Date
unsafeFromString string =
  case Date.fromString string of
      Ok date -> date
      Err msg -> Debug.crash("unsafeFromString")

fetchDeliveries : Model -> Cmd Msg
fetchDeliveries model =
  let
    (from, to) = model.window
    url = "/api/deliveries?include=user&filter[from]=" ++ from ++ "&filter[to]=" ++ to
  in
    Task.perform FetchFail FetchSucceed (JsonApi.get decodeDeliveriesFetch url)

decodeDeliveriesFetch : Json.Decoder JsonModel
decodeDeliveriesFetch =
  Json.object1 JsonModel
    ("data" := Json.list decodeDeliveries)

decodeDeliveries : Json.Decoder Delivery.Model
decodeDeliveries =
  Json.object3 Delivery.Model
    (Json.at ["attributes", "date"] Json.string)
    (Json.at ["attributes", "date"] Json.string)
    (Json.at ["attributes", "date"] Json.string)

renderView : Model -> Html Msg
renderView model =
  let
    width = 1200
    height = 600
    calendar =
      model.calendar.form
      |> Collage.moveX (-width/2)
      |> Collage.moveY (height/2 - 100) -- FIXME 100
  in
    Collage.collage width height [calendar]
    |> Element.toHtml

view : Model -> Html Msg
view model =
  if model.fetching then
    i [ class "fa fa-spinner fa-pulse fa-3x fa-fw" ] []
  else
    renderView model
