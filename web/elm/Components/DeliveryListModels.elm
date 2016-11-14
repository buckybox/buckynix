module Components.DeliveryListModels exposing (..)

import Collage exposing (Form)
import Text
import Date exposing (Date)
import Time exposing (Time)
import Dict exposing (Dict)

import Lib.UUID exposing (UUID)
import Lib.DateExtra as DateExtra

import Components.Delivery as Delivery

type alias Window = (String, String)
emptyWindow : Window
emptyWindow =
  ("1970-01-01", "1970-01-01")

dateWindow : Window -> (Time, Time)
dateWindow window =
  (
    fst window |> DateExtra.unsafeFromString |> Date.toTime,
    snd window |> DateExtra.unsafeFromString |> Date.toTime
  )

type alias Calendar =
  { form: Form } -- FIXME: move to top-level if no other data needed

type DayState = Delivered | Pending | Open

type alias Day =
  { date: Date
  , state: DayState
  , deliveryCount: Int }

type alias Model =
  { calendar: Calendar
  , selectedWindow: Window
  , visibleWindow: Window
  , allDeliveries: Dict UUID Delivery.Model
  , selectedDeliveries: List Delivery.Model
  , fetching: Bool }

initialModel : Model
initialModel =
  { calendar = { form = Text.fromString "..." |> Collage.text }
  , selectedWindow = emptyWindow
  , visibleWindow = emptyWindow
  , allDeliveries = Dict.empty
  , selectedDeliveries = []
  , fetching = False }
