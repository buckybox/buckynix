module DeliveryListApp exposing (..)

import Html exposing (Html, div)
import Html.App
import Task exposing (Task)
import Collage exposing (Form)
import Text
import String
import Color exposing (Color)
import Element exposing (Element)
import Date exposing (Date)

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

type alias Window =
  { from: Day
  , to: Day }

type alias Calendar =
  { days: List Day
  , selectedWindow: Window }

type alias Model =
  { form: Form }

initialModel : Model
initialModel =
  let
    day = Day (Date.fromTime 1468454400) Delivered 42
    days = List.repeat 30 day
    window = Window day day
    calendar = Calendar days window

    width = 30 + 1 -- add 1 px for border
    xPositions = List.map (\x -> toFloat(x) * width) [1..(List.length days)]
  in
      { form =
          List.map2 (\day -> \x -> renderDay day |> Collage.moveX x)
          calendar.days
          xPositions
          |> Collage.group
      }

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

init : (Model, Cmd Action)
init =
  (initialModel, Task.perform (always Init) (always Init) (Task.succeed 0))

type Action
  = Init

update : Action -> Model -> (Model, Cmd Action)
update msg model =
  case msg of
    Init ->
      (model, Cmd.none)

view : Model -> Html Action
view model =
  div [] [ renderView model ]

renderView : Model -> Html Action
renderView model =
  let
    width = 1200
    height = 600
    form =
      model.form
      |> Collage.moveX (-width/2)
      |> Collage.moveY (height/2 - 100) -- FIXME 100
  in
    Collage.collage width height [form]
    |> Element.toHtml

subscriptions : Model -> Sub Action
subscriptions model =
  Sub.none

main : Program Never
main =
  Html.App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
