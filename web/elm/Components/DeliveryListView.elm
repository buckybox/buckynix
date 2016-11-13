module Components.DeliveryListView exposing (view, calendarForm)

import Html exposing (..)
import Html.Attributes exposing (..)

import Collage exposing (Form)
import Text
import String
import Color exposing (Color)
import Element exposing (Element)
import Date exposing (Date)
import Dict exposing (Dict)

import Lib.DateExtra exposing (unsafeFromString)

import Components.DeliveryListModels exposing (..)
import Components.Delivery as Delivery

calendarWidth : Float
calendarWidth = 1110

fontHeight : Float
fontHeight = 10

barWidth : Float
barWidth = 40

maxBarHeight : Float
maxBarHeight = 100

dayStateColor : DayState -> Color
dayStateColor state =
  case state of
    Delivered -> Color.rgb 204 204 204
    Pending   -> Color.rgb 255 220 90
    Open      -> Color.rgb 0 168 23

calendarForm : List Delivery.Model -> Form
calendarForm deliveries =
  let
    days =
      List.foldr
        (\delivery -> \dict -> buildDays delivery dict)
        (Dict.empty)
        deliveries
   in
     buildCalendar (Dict.values days)

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

buildCalendar : List Day -> Form
buildCalendar days =
  let
    width = barWidth + 1 -- add 1 px for border
    xPositions = List.map (\x -> toFloat(x) * width) [1..(List.length days)]
    maxCount =
      List.map (\day -> day.deliveryCount) days
      |> List.maximum
      |> Maybe.withDefault 0
  in
    List.map2 (\day -> \x -> calendarDay day maxCount |> Collage.moveX x) days xPositions
    |> Collage.group

calendarDay : Day -> Int -> Form
calendarDay day maxCount =
  let
    count = day.deliveryCount
    height = (maxBarHeight * toFloat(count) / toFloat(maxCount))
    dow = toString (Date.dayOfWeek day.date) |> String.left 1
  in
    Collage.group
    [
      Text.fromString (toString count)
      |> Collage.text
      |> Collage.moveY (height / 2 + fontHeight)
    ,
      Collage.rect barWidth height
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
    |> Collage.moveY (height / 2)

calendarView : Model -> Html msg
calendarView model =
  let
    height = maxBarHeight + 50 -- add 50 for padding
    calendar =
      model.calendar.form
      |> Collage.moveX (-calendarWidth / 2)
      |> Collage.moveY (-height / 2 + fontHeight * 2)
    html = Collage.collage (truncate calendarWidth) (truncate height) [calendar]
      |> Element.toHtml
  in
    div [ style [("background", "rgba(0,0,0,.01)")] ] [ html ]

deliveryView : Model -> Html msg
deliveryView model =
  let
    rows = List.map
      (\delivery -> Delivery.view delivery)
      model.selectedDeliveries
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

view : Model -> Html msg
view model =
  if model.fetching then
    div [ class "text-center" ]
      [ i [ class "fa fa-spinner fa-pulse fa-3x fa-fw" ] [] ]
  else
    div []
      [ calendarView model
      , deliveryView model ]
