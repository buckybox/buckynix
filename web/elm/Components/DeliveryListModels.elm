module Components.DeliveryListModels exposing (..)

import Collage exposing (Form)
import Text
import Date exposing (Date)

import Components.Delivery as Delivery

type alias Window = (String, String)

type alias Calendar =
  { form: Form }

type DayState = Delivered | Pending | Open

type alias Day =
  { date: Date
  , state: DayState
  , deliveryCount: Int }

type alias Model =
  { calendar: Calendar
  , window: Window
  , deliveries: List Delivery.Model
  , fetching: Bool }

initialModel : Model
initialModel =
  { calendar = { form = Text.fromString "..." |> Collage.text }
  , window = ("", "")
  , deliveries = []
  , fetching = False }
