module Components.TransactionListView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List
import Components.Transaction as Transaction
import Components.TransactionListModel exposing (..)


view : Model -> Html Msg
view model =
    div [] [ renderTransactions model ]


renderTransactions : Model -> Html Msg
renderTransactions model =
    let
        moreLinkWrapper =
            if model.fetchAll then
                []
            else
                [ moreLink model.fetching ]

        rows =
            List.map (\transaction -> Transaction.view transaction) model.transactions
    in
        div [ class "row" ]
            [ div [ class "col-xs" ]
                [ table [ class "table table-striped table-sm" ]
                    [ thead [] [ tableHead ]
                    , tbody [] rows
                    , tfoot [] moreLinkWrapper
                    ]
                ]
            ]


tableHead : Html Msg
tableHead =
    tr []
        [ th [] [ text "Creation Date" ]
        , th [] [ text "Value Date" ]
        , th [] [ text "Description" ]
        , th [ class "text-right" ] [ text "Amount" ]
        , th [ class "text-right" ] [ text "Balance" ]
        ]


addLink : Html Msg
addLink =
    tr []
        [ td [ colspan 5 ]
            [ a [ href "/users/new", class "btn btn-outline-warning btn-block" ] [ text "Add" ] ]
        ]


moreLink : Bool -> Html Msg
moreLink fetching =
    let
        tag =
            if fetching then
                i [ class "fa fa-spinner fa-pulse fa-3x fa-fw" ] []
            else
                a [ href "javascript:void(0)", onClick Fetch ] [ text "show all" ]
    in
        tr []
            [ td [ colspan 5, class "text-center" ] [ tag ] ]
