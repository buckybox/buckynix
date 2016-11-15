module TransactionListApp exposing (..)

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
    ( initialModel flags.userId, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fetch ->
            ( { model | fetching = True }, fetchTransactions model )

        FetchSucceed jsonModel ->
            let
                transactionList =
                    jsonModel.data
            in
                ( { model
                    | transactions = transactionList
                    , fetching = False
                  }
                , Cmd.none
                )

        FetchFail error ->
            ( { model | fetching = False }, Cmd.none )


fetchTransactions : Model -> Cmd Msg
fetchTransactions model =
    let
        url =
            "/api/users/" ++ model.userId ++ "/transactions"
    in
        Task.perform FetchFail FetchSucceed (JsonApiExtra.get TransactionListDecoder.decodeTransactionFetch url)


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
