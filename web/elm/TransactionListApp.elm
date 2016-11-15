module TransactionListApp exposing (main)

import Html exposing (Html)
import Html.App
import Task
import Lib.JsonApiExtra as JsonApiExtra
import Components.TransactionListModel exposing (..)
import Components.TransactionListView as TransactionListView
import Components.TransactionListDecoder as TransactionListDecoder


type alias Flags =
    { userId : String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        userId =
            flags.userId
    in
        ( initialModel userId, fetchTransactions userId )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fetch ->
            ( { model | fetching = True }, fetchTransactions model.userId )

        FetchSucceed document ->
            let
                transactions =
                    TransactionListDecoder.decodeTransactions document
            in
                ( { model
                    | transactions = transactions
                    , fetching = False
                  }
                , Cmd.none
                )

        FetchFail error ->
            ( { model | fetching = False }, Cmd.none )


request : String -> Cmd Msg
request url =
    Task.perform FetchFail FetchSucceed <|
        JsonApiExtra.get TransactionListDecoder.decodeDocument url


fetchTransactions : String -> Cmd Msg
fetchTransactions userId =
    "/api/users/"
        ++ userId
        ++ "/transactions"
        |> request


view : Model -> Html Msg
view model =
    TransactionListView.view model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Flags
main =
    Html.App.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
