port module DeliveryListApp exposing (..)

import Html exposing (Html, Attribute, div)
import Html.Events exposing (on)
import Json.Decode as Json
import Html.App

import Mouse exposing (Position)

import Components.DeliveryListModels as DeliveryListModels
import Components.DeliveryListView as DeliveryListView
import Components.DeliveryListCalendar as DeliveryListCalendar

type alias Model =
  { calendar: DeliveryListModels.Model
  , position: Position
  , drag: Maybe Drag }

init : (Model, Cmd Msg)
init =
  ( { calendar = DeliveryListModels.initialModel
    , position = Position 0 0
    , drag = Nothing }
  , Cmd.none )

type Msg
  = DeliveryListCalendarMsg DeliveryListCalendar.Msg
  | JsMsg (List String)
  | DragStart Position
  | DragAt Position
  | DragEnd Position

type alias Drag =
  { start: Position
  , current: Position }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    DeliveryListCalendarMsg msg ->
      let (updatedModel, cmd) = DeliveryListCalendar.update msg model.calendar
      in ( { model | calendar = updatedModel }, Cmd.map DeliveryListCalendarMsg cmd )

    JsMsg ["DeliveryList.FetchVisibleWindow", from, to] ->
      let (updatedModel, cmd) = DeliveryListCalendar.update (DeliveryListCalendar.FetchVisibleWindow (from, to)) model.calendar
      in ( { model | calendar = updatedModel }, Cmd.map DeliveryListCalendarMsg cmd )

    JsMsg ["DeliveryList.FetchSelectedWindow", from, to] ->
      let (updatedModel, cmd) = DeliveryListCalendar.update (DeliveryListCalendar.FetchSelectedWindow (from, to)) model.calendar
      in ( { model | calendar = updatedModel }, Cmd.map DeliveryListCalendarMsg cmd )

    JsMsg _ ->
      (model, Cmd.none)

    DragStart xy ->
      let updatedModel = { model | drag = Just (Drag xy xy) }
      in ( updatedModel, Cmd.none )

    DragAt xy ->
      let updatedModel = { model | drag = (Maybe.map (\{start} -> Drag start xy) model.drag) }
      in ( updatedModel, Cmd.none )

    DragEnd _ ->
      let updatedModel = { model | drag = Nothing, position = getPosition model }
      in ( updatedModel, Cmd.none )

deliveryListView : Model -> Html Msg
deliveryListView model =
  Html.App.map DeliveryListCalendarMsg (DeliveryListView.view model.calendar)

view : Model -> Html Msg
view model =
  div [ onMouseDown ]
    [ div [] [ Html.text (toString model.position.x) ]
    , div [] [ deliveryListView model ] ]

subscriptions : Model -> Sub Msg
subscriptions model =
  case model.drag of
    Nothing ->
      Sub.batch [ jsEvents JsMsg ]
    Just _ ->
      Sub.batch [ jsEvents JsMsg, Mouse.moves DragAt, Mouse.ups DragEnd ]

getPosition : Model -> Position
getPosition {position, drag} =
  case drag of
    Nothing ->
      position
    Just {start, current} ->
      Position (current.x - start.x) (current.y - start.y)

onMouseDown : Html.Attribute Msg
onMouseDown =
  on "mousedown" (Json.map DragStart Mouse.position)

-- port for listening for events from JavaScript
port jsEvents : (List String -> msg) -> Sub msg

main : Program Never
main =
  Html.App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
