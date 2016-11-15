module Components.DeliveryListModel exposing (..)

import Http exposing (Error)
import Date exposing (Date)
import Time exposing (Time)
import Dict exposing (Dict)
import Collage exposing (Form)
import Element
import Mouse exposing (Position)
import JsonApi exposing (Document)
import Lib.UUID exposing (UUID)
import Lib.DateExtra as DateExtra
import Components.Delivery as Delivery


type Msg
    = JsMsg (List String)
    | FetchSucceedSelectedWindow Document
    | FetchSucceedVisibleWindow Document
    | FetchFail Http.Error
    | DragStartSelectedWindowFrom Position
    | DragStartSelectedWindowTo Position
    | DragAt Position
    | DragEnd Position


type alias Window =
    { from : Time
    , to : Time
    }


emptyWindow : Window
emptyWindow =
    fromStringWindow "1970-01-01" "1970-01-01"


fromStringWindow : String -> String -> Window
fromStringWindow from to =
    Window
        (from |> DateExtra.unsafeFromString |> Date.toTime)
        (to |> DateExtra.unsafeFromString |> Date.toTime)


toStringWindow : Window -> ( String, String )
toStringWindow { from, to } =
    ( from |> Date.fromTime |> DateExtra.toISOString
    , to |> Date.fromTime |> DateExtra.toISOString
    )


type DayState
    = Delivered
    | Pending
    | Open


type alias Day =
    { date : Date
    , state : DayState
    , deliveryCount : Int
    }


type alias Drag =
    { start : Position
    , current : Position
    }


type DragElement
    = SelectedWindowFrom
    | SelectedWindowTo


type alias Model =
    { calendar : Form
    , selectedWindow : Window
    , visibleWindow : Window
    , tempWindow : Window
    , allDeliveries : Dict UUID Delivery.Model
    , selectedDeliveries : List Delivery.Model
    , fetching : Bool
    , position : Position
    , drag : Maybe Drag
    , dragElement : DragElement
    }


initialModel : Model
initialModel =
    { calendar = Element.empty |> Collage.toForm
    , selectedWindow = emptyWindow
    , visibleWindow = emptyWindow
    , tempWindow = emptyWindow
    , allDeliveries = Dict.empty
    , selectedDeliveries = []
    , fetching = False
    , position = Position 0 0
    , drag = Nothing
    , dragElement = SelectedWindowFrom
    }
