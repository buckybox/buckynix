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

import Components.DeliveryListModels exposing (..)
import Components.Delivery as Delivery

dayStateColor : DayState -> Color
dayStateColor state =
  case state of
    Delivered -> Color.rgb 204 204 204
    Pending   -> Color.rgb 255 220 90
    Open      -> Color.rgb 0 168 23

calendarForm : List Day -> Form
calendarForm days =
  let
    width = 30 + 1 -- add 1 px for border
    xPositions = List.map (\x -> toFloat(x) * width) [1..(List.length days)]
  in
    List.map2 (\day -> \x -> calendarDay day |> Collage.moveX x) days xPositions
    |> Collage.group

calendarDay : Day -> Form
calendarDay day =
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

calendarView : Model -> Html msg
calendarView model =
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

deliveryView : Model -> Html msg
deliveryView model =
  let
    rows = List.map
      (\delivery -> Delivery.view delivery)
      (Dict.values model.selectedDeliveries)
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
