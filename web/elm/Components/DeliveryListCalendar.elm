module Components.DeliveryListCalendar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

import Http exposing (Error)
import Task
import Json.Decode as Json exposing ((:=), andThen)

import JsonApi.Decode
import JsonApi.Documents
import JsonApi.Resources
import JsonApi exposing (Document, Resource)

import Collage exposing (Form)
import Text
import String
import Dict exposing (Dict)
import Color exposing (Color)
import Element exposing (Element)
import Date exposing (Date)

import Components.JsonApiExtra exposing (get)
import Components.Delivery as Delivery
import Components.User as User

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
  { form: Form }

type alias Model =
  { calendar: Calendar
  , window: Window
  , deliveries: List Delivery.Model
  , fetching: Bool }

initialModel : Model
initialModel =
  { calendar =
    { form = Text.fromString "..." |> Collage.text }
  , window = ("", "")
  , deliveries = []
  , fetching = False }

type alias JsonModel =
  { deliveries: List Delivery.Model }

createCalendarForm : List Day -> Form
createCalendarForm days =
  let
    width = 30 + 1 -- add 1 px for border
    xPositions = List.map (\x -> toFloat(x) * width) [1..(List.length days)]
  in
    List.map2 (\day -> \x -> createCalendarDay day |> Collage.moveX x) days xPositions
    |> Collage.group

createCalendarDay : Day -> Form
createCalendarDay day =
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
  | FetchSucceed Document
  | FetchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Fetch window ->
      ({ model | fetching = True, window = window }, fetchDeliveries window)
    FetchSucceed document ->
      let
        deliveries = decodeDeliveries document
        days =
          List.foldr
            (\delivery -> \dict -> updateDays delivery dict)
            Dict.empty
            deliveries
          |> Dict.values
        form = createCalendarForm days
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

unsafeFromString : String -> Date
unsafeFromString string =
  case Date.fromString string of
      Ok date -> date
      Err msg -> Debug.crash("unsafeFromString")

fetchDeliveries : Window -> Cmd Msg
fetchDeliveries window =
  let
    (from, to) = window
    url = "/api/deliveries?include=user&filter[from]=" ++ from ++ "&filter[to]=" ++ to
  in
    Task.perform FetchFail FetchSucceed (get decodeDocument url)

decodeDocument : Json.Decoder Document
decodeDocument =
  JsonApi.Decode.document

decodeDeliveries : Document -> List Delivery.Model
decodeDeliveries document =
  case JsonApi.Documents.primaryResourceCollection document of
    Err error -> Debug.crash error
    Ok deliveries ->
      List.map (\delivery -> decodeDeliveriesAttributes delivery) deliveries

decodeDeliveriesAttributes : Resource -> Delivery.Model
decodeDeliveriesAttributes delivery =
  case JsonApi.Resources.attributes deliveryDecoder delivery of
    Err error -> Debug.crash error
    Ok delivery -> delivery

deliveryDecoder : Json.Decoder Delivery.Model
deliveryDecoder =
  Json.object3 Delivery.Model
    ("date" := Json.string)
    ("date" := Json.string) -- FIXME
    ("date" := Json.string) -- FIXME

  -- Json.object4 Delivery.Model
  --   (Json.at ["attributes", "date"] Json.string)
  --   ((Json.at ["relationships", "user", "data", "id"]) `andThen` decodeUser)
  --   (JsonApi.Resources.relatedResource "user" decodedPrimaryResource)
  --   (Json.at ["attributes", "date"] Json.string)
  --   (Json.at ["attributes", "date"] Json.string)

-- decodeUser : String -> Json.Decoder User.Model
-- decodeUser id =
  -- Json.object4 User.Model
    -- (Json.at ["included", _, 

    -- { url = id
    -- , name = id
    -- , balance = "?"
    -- , tags = [] }


renderCalendarView : Model -> Html Msg
renderCalendarView model =
  let
    width = 1200
    height = 200
    calendar =
      model.calendar.form
      |> Collage.moveX (-width/2)
      |> Collage.moveY (height/2 - 100) -- FIXME 100
  in
    Collage.collage width height [calendar]
    |> Element.toHtml

renderDeliveryView : Model -> Html Msg
renderDeliveryView model =
  let
    rows = List.map (\delivery -> Delivery.view delivery) model.deliveries
    moreLinkWrapper = []
  in
    div [ class "row mt-3" ]
      [ div [ class "col-xs" ]
        [ table [ class "table table-striped table-sm" ]
          [ thead [] []
          , tbody [] rows
          , tfoot [] moreLinkWrapper ]
        ]
      ]

view : Model -> Html Msg
view model =
  if model.fetching then
    div [ class "text-center" ]
      [ i [ class "fa fa-spinner fa-pulse fa-3x fa-fw" ] [] ]
  else
    div []
      [ renderCalendarView model
      , renderDeliveryView model ]
