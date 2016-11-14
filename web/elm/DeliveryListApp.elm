port module DeliveryListApp exposing (..)

import Html.App
import Html exposing (Html, Attribute, div)
import Html.Events exposing (on)
import Json.Decode as Json
import Mouse exposing (Position)

import Dict exposing (Dict)
import Task exposing (Task)
import Http exposing (Error)
import JsonApi exposing (Document)

import Lib.JsonApiExtra as JsonApiExtra

import Components.DeliveryListModel exposing (..)
import Components.DeliveryListDecoder as DeliveryListDecoder
import Components.DeliveryListView as DeliveryListView

init : (Model, Cmd Msg)
init =
  ( initialModel, Cmd.none )

type Msg
  = JsMsg (List String)
  | FetchSucceedSelectedWindow Document
  | FetchSucceedVisibleWindow Document
  | FetchFail Http.Error
  | DragStart Position
  | DragAt Position
  | DragEnd Position

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    FetchSucceedSelectedWindow document ->
      let
        selectedDeliveries =
          DeliveryListDecoder.decodeDeliveries document
          |> Dict.values
      in
        ( { model | fetching = False, selectedDeliveries = selectedDeliveries }
        , Cmd.none )

    FetchSucceedVisibleWindow document ->
      let
        newDeliveries = DeliveryListDecoder.decodeDeliveries document
        allDeliveries = Dict.union model.allDeliveries newDeliveries
      in
        ( { model | fetching = False, allDeliveries = allDeliveries }
        , Cmd.none )

    FetchFail error ->
      ( { model | fetching = False }
      , Cmd.none )

    JsMsg ["DeliveryList.FetchVisibleWindow", from, to] ->
      let
        window = fromStringWindow from to
      in
        ( { model | fetching = True, visibleWindow = window }
        , fetchVisibleWindow window )

    JsMsg ["DeliveryList.FetchSelectedWindow", from, to] ->
      let
        window = fromStringWindow from to
      in
        ( { model | fetching = True, selectedWindow = window }
        , fetchSelectedWindow window )

    JsMsg _ ->
      ( model
      , Cmd.none )

    DragStart position ->
      ( { model | drag = Just (Drag position position) }
      , Cmd.none )

    DragAt position ->
      ( { model | drag = (Maybe.map (\{start} -> Drag start position) model.drag) }
      , Cmd.none )

    DragEnd _ ->
      ( { model | drag = Nothing, position = getPosition model }
      , Cmd.none )

request : (Document -> Msg) -> String -> Cmd Msg
request succeedMsg url =
  Task.perform FetchFail succeedMsg
  <| JsonApiExtra.get DeliveryListDecoder.decodeDocument url

fetchSelectedWindow : Window -> Cmd Msg
fetchSelectedWindow window =
  let
    (from, to) = toStringWindow window
  in
    "/api/deliveries?include=user&filter[from]=" ++ from ++ "&filter[to]=" ++ to
    |> request FetchSucceedSelectedWindow

fetchVisibleWindow : Window -> Cmd Msg
fetchVisibleWindow window =
  let
    (from, to) = toStringWindow window
  in
    "/api/deliveries?filter[from]=" ++ from ++ "&filter[to]=" ++ to
    |> request FetchSucceedVisibleWindow

view : Model -> Html Msg
view model =
  let
    x1 = case model.drag of
      Nothing -> -1
      Just drag -> drag.current.x - drag.start.x
  in
  div [ onMouseDown ]
    [ div [] [ Html.text (toString x1) ]
    , div [] [ DeliveryListView.view model ] ]

subscriptions : Model -> Sub Msg
subscriptions model =
  case model.drag of
    Nothing ->
      -- XXX: don't subscribe to Move events to help with performance, see
      -- http://package.elm-lang.org/packages/elm-lang/mouse/latest/Mouse#moves
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
