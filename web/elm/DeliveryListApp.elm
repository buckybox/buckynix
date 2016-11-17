port module DeliveryListApp exposing (main)

import Html.App
import Html exposing (Html, Attribute, div)
import Mouse exposing (Position)
import Dict exposing (Dict)
import Task exposing (Task)
import Time exposing (Time)
import JsonApi exposing (Document)
import Lib.JsonApiExtra as JsonApiExtra
import Components.DeliveryListModel exposing (..)
import Components.DeliveryListDecoder as DeliveryListDecoder
import Components.DeliveryListView as DeliveryListView


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchSucceedSelectedWindow document ->
            let
                selectedDeliveries =
                    DeliveryListDecoder.decodeDeliveries document
                        |> Dict.values
                        |> List.sortBy .date
            in
                ( { model | fetching = False, selectedDeliveries = selectedDeliveries }
                , Cmd.none
                )

        FetchSucceedVisibleWindow document ->
            let
                newDeliveries =
                    DeliveryListDecoder.decodeDeliveries document

                allDeliveries =
                    Dict.union model.allDeliveries newDeliveries
            in
                ( { model | fetching = False, allDeliveries = allDeliveries }
                , Cmd.none
                )

        FetchFail error ->
            ( { model | fetching = False }
            , Cmd.none
            )

        JsMsg [ "DeliveryList.FetchVisibleWindow", from, to ] ->
            let
                window =
                    fromStringWindow from to
            in
                ( { model | fetching = True, visibleWindow = window }
                , fetchVisibleWindow window
                )

        JsMsg [ "DeliveryList.FetchSelectedWindow", from, to ] ->
            let
                window =
                    fromStringWindow from to
            in
                ( { model | fetching = True, selectedWindow = window }
                , fetchSelectedWindow window
                )

        JsMsg _ ->
            ( model
            , Cmd.none
            )

        DragStartSelectedWindowFrom position ->
            registerDragStart SelectedWindowFrom position model

        DragStartSelectedWindowTo position ->
            registerDragStart SelectedWindowTo position model

        DragAt position ->
            ( { model | selectedWindow = updateWindow model position }
            , Cmd.none
            )

        DragEnd _ ->
            ( { model | drag = Nothing, position = getPosition model }
            , fetchSelectedWindow model.selectedWindow
            )


registerDragStart : DragElement -> Position -> Model -> ( Model, Cmd Msg )
registerDragStart dragElement position model =
    ( { model
        | drag = Just (Drag position position)
        , dragElement = dragElement
        , tempWindow = model.selectedWindow
      }
    , Cmd.none
    )


updateWindow : Model -> Position -> Window
updateWindow model position =
    let
        dx =
            case model.drag of
                Nothing ->
                    0

                Just drag ->
                    position.x - drag.start.x

        dt =
            toFloat dx
                / DeliveryListView.barWidthWithMargin
                |> round
                -- round to snap to whole days
                |>
                    toFloat
                |> (*) (86400 * Time.second)

        window =
            model.tempWindow
    in
        case model.dragElement of
            SelectedWindowFrom ->
                { window
                    | from =
                        max model.visibleWindow.from
                            (min window.to (window.from + dt))
                }

            SelectedWindowTo ->
                { window
                    | to =
                        min model.visibleWindow.to
                            (max window.from (window.to + dt))
                }


getPosition : Model -> Position
getPosition { position, drag } =
    case drag of
        Nothing ->
            position

        Just { start, current } ->
            Position (current.x - start.x) (current.y - start.y)


request : (Document -> Msg) -> String -> Cmd Msg
request succeedMsg url =
    Task.perform FetchFail succeedMsg <|
        JsonApiExtra.get DeliveryListDecoder.decodeDocument url


fetchSelectedWindow : Window -> Cmd Msg
fetchSelectedWindow window =
    let
        ( from, to ) =
            toStringWindow window
    in
        "/api/deliveries?include=user,address.street&filter[from]="
            ++ from
            ++ "&filter[to]="
            ++ to
            |> request FetchSucceedSelectedWindow


fetchVisibleWindow : Window -> Cmd Msg
fetchVisibleWindow window =
    let
        ( from, to ) =
            toStringWindow window
    in
        "/api/deliveries?filter[from]="
            ++ from
            ++ "&filter[to]="
            ++ to
            |> request FetchSucceedVisibleWindow


view : Model -> Html Msg
view model =
    div [] [ div [] [ DeliveryListView.view model ] ]


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.drag of
        Nothing ->
            -- XXX: don't subscribe to Move events to help with performance, see
            -- http://package.elm-lang.org/packages/elm-lang/mouse/latest/Mouse#moves
            Sub.batch [ jsEvents JsMsg ]

        Just _ ->
            Sub.batch [ jsEvents JsMsg, Mouse.moves DragAt, Mouse.ups DragEnd ]



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
