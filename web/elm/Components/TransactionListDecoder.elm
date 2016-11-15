module Components.TransactionListDecoder exposing (..)

import Json.Decode as Json exposing ((:=))
import Components.Transaction as Transaction
import Components.TransactionListModel exposing (JsonModel)


decodeTransactionFetch : Json.Decoder JsonModel
decodeTransactionFetch =
    Json.object1 JsonModel
        ("data" := Json.list decodeTransactionData)


decodeTransactionData : Json.Decoder Transaction.Model
decodeTransactionData =
    Json.object5 Transaction.Model
        (Json.at [ "attributes", "inserted-at" ] Json.string)
        (Json.at [ "attributes", "value-date" ] Json.string)
        (Json.at [ "attributes", "description" ] Json.string)
        (Json.at [ "attributes", "amount" ] Json.string)
        (Json.at [ "attributes", "balance" ] Json.string)
