port module DeliveryListApp exposing (..)

import Html exposing (Html, div)
import Html.App

import Components.DeliveryListCalendar as DeliveryListCalendar

type alias Model =
  { calendar: DeliveryListCalendar.Model }

init : (Model, Cmd Msg)
init =
  ( { calendar = DeliveryListCalendar.initialModel }, Cmd.none )

type Msg
  = DeliveryListCalendarMsg DeliveryListCalendar.Msg
  | JsMsg (List String)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    DeliveryListCalendarMsg msg ->
      let (updatedModel, cmd) = DeliveryListCalendar.update msg model.calendar
      in ( { model | calendar = updatedModel }, Cmd.map DeliveryListCalendarMsg cmd )
    JsMsg ["DeliveryList.Fetch", from, to] ->
      let (updatedModel, cmd) = DeliveryListCalendar.update (DeliveryListCalendar.Fetch (from, to)) model.calendar
      in ( { model | calendar = updatedModel }, Cmd.map DeliveryListCalendarMsg cmd )
    JsMsg _ ->
      (model, Cmd.none)

deliveryListView : Model -> Html Msg
deliveryListView model =
  Html.App.map DeliveryListCalendarMsg (DeliveryListCalendar.view model.calendar)

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
