module TransactionListApp exposing (main)

import Html exposing (Html)
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

        FetchResult (Ok document) ->
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

        FetchResult (Err error) ->
            ( { model | fetching = False }, Cmd.none )


request : String -> Cmd Msg
request url =
    JsonApiExtra.get url FetchResult TransactionListDecoder.decodeDocument


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


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
