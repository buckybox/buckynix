port module DeliveryListApp exposing (..)

import Html exposing (Html, div)
import Html.App

import Components.DeliveryListModels as DeliveryListModels
import Components.DeliveryListView as DeliveryListView
import Components.DeliveryListCalendar as DeliveryListCalendar

type alias Model =
  { calendar: DeliveryListModels.Model }

init : (Model, Cmd Msg)
init =
  ( { calendar = DeliveryListModels.initialModel }, Cmd.none )

type Msg
  = DeliveryListCalendarMsg DeliveryListCalendar.Msg
  | JsMsg (List String)

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

deliveryListView : Model -> Html Msg
deliveryListView model =
  Html.App.map DeliveryListCalendarMsg (DeliveryListView.view model.calendar)

view : Model -> Html Msg
view model =
  div [] [ deliveryListView model ]

subscriptions : Model -> Sub Msg
subscriptions model =
  jsEvents JsMsg

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
