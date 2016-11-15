module Components.DeliveryListView exposing (view, barWidthWithMargin)

import Html exposing (..)
import Html.Attributes exposing (..)

import Collage exposing (Form)
import Text
import String
import Color exposing (Color)
import Element exposing (Element)
import Date exposing (Date)
import Time exposing (Time)
import Dict exposing (Dict)

import Html.Events exposing (on)
import Json.Decode as Json
import Mouse exposing (Position)

import Lib.DateExtra as DateExtra

import Components.DeliveryListModel exposing (..)
import Components.Delivery as Delivery

calendarWidth : Float
calendarWidth = 1110

fontHeight : Float
fontHeight = 10

barWidth : Float
barWidth = 36

barMargin : Float
barMargin = 1

barWidthWithMargin : Float
barWidthWithMargin = barWidth + barMargin

maxBarHeight : Float
maxBarHeight = 100

onMouseDown : (Position -> Msg) -> Html.Attribute Msg
onMouseDown msg =
  on "mousedown" (Json.map msg Mouse.position)

dayColor : Day -> Color
dayColor day =
  let
    colorTuple = case day.state of
      Delivered -> (Color.grey,   Color.darkGrey)
      Pending   -> (Color.yellow, Color.darkYellow)
      Open      -> (Color.green,  Color.darkGreen)
   in
     if DateExtra.isWeekend day.date then
       snd colorTuple
     else
       fst colorTuple

generateCalendar : List Delivery.Model -> Window -> Form
generateCalendar deliveries visibleWindow =
  let
    paddingDays = buildEmptyDays visibleWindow
    deliveryDays =
      List.foldr
        (\delivery -> \dict -> buildDays delivery dict)
        (Dict.empty)
        deliveries
    days = Dict.union deliveryDays paddingDays |> Dict.values
   in
     buildCalendar days

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
          { date = DateExtra.unsafeFromString date
          , state = Pending
          , deliveryCount = 1 }
          days

buildEmptyDays : Window -> Dict String Day
buildEmptyDays {from, to} =
  let
    duration = DateExtra.diffDays from to
    emptyDays = List.map
      (\offset ->
        { date = Date.fromTime (from + offset * (86400 * Time.second))
        , state = Open
        , deliveryCount = 0 }
      )
      [0..duration]
  in
    List.foldr
      (\day -> \dict -> Dict.insert (DateExtra.toISOString day.date) day dict)
      Dict.empty
      emptyDays

buildCalendar : List Day -> Form
buildCalendar days =
  let
    xPositions = List.map (\x -> toFloat(x) * barWidthWithMargin) [1..(List.length days)]
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
    minHeight = fontHeight * 2
    height = (maxBarHeight - minHeight) * toFloat(count) / toFloat(maxCount) + minHeight
    dow = toString (Date.dayOfWeek day.date) |> String.left 1
  in
    Collage.group
    [
      Text.fromString (toString count)
      |> Collage.text
      |> Collage.moveY (height / 2 + fontHeight)
    ,
      Collage.rect barWidth height
      |> Collage.filled (dayColor day)
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

calendarView : Model -> Html Msg
calendarView model =
  let
    height = maxBarHeight + 50 -- add 50 for padding
    calendar =
      generateCalendar (Dict.values model.allDeliveries) model.visibleWindow
      |> Collage.moveX (-calendarWidth / 2)
      |> Collage.moveY (-height / 2 + fontHeight * 2)
    html = Collage.collage (truncate calendarWidth) (truncate height) [calendar]
      |> Element.toHtml
  in
    div [ class "bg-faded" ] [ html ]

controlView : Model -> Html Msg
controlView model =
  let
    (selectedFrom, selectedTo) = (model.selectedWindow.from, model.selectedWindow.to)
    (visibleFrom, _) = (model.visibleWindow.from, model.visibleWindow.to)
    fromOffset = DateExtra.diffDays visibleFrom selectedFrom
    toOffset = DateExtra.diffDays visibleFrom selectedTo
    iconWidth = 5
    fromPosition = fromOffset * barWidthWithMargin + iconWidth - barMargin
    toPosition = (toOffset + 1) * barWidthWithMargin - iconWidth - barMargin

    fromIcon = i [
      onMouseDown DragStartSelectedWindowFrom,
      class "fa fa-step-backward", style
      [ ("left", (toString fromPosition) ++ "px")
      , ("position", "relative")
      , ("cursor", "col-resize") ]
    ] []
    toIcon = i [
      onMouseDown DragStartSelectedWindowTo,
      class "fa fa-step-forward", style
      [ ("left", (toString toPosition) ++ "px")
      , ("position", "relative")
      , ("cursor", "col-resize") ]
    ] []
  in
    div [ class "col-xs bg-faded pb-4" ]
      [ span [ style [("position", "absolute")] ] [ fromIcon ]
      , span [ style [("position", "absolute")] ] [ toIcon ] ]

deliveryView : Model -> Html Msg
deliveryView model =
  let
    rows = case model.selectedDeliveries of
      [] -> [ tr
            [ class "text-center" ]
            [ td [] [ text "No delieries for this date range" ] ] ]

      _  -> List.map
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

view : Model -> Html Msg
view model =
  if model.fetching then
    div [ class "text-center" ]
      [ i [ class "fa fa-spinner fa-pulse fa-3x fa-fw" ] [] ]
  else
    div []
      [ calendarView model
      , controlView model
      , deliveryView model ]
