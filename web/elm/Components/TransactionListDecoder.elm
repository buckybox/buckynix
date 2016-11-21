module Components.TransactionListDecoder exposing (decodeDocument, decodeTransactions)

import Json.Decode as Json
import JsonApi.Decode
import JsonApi.Documents
import JsonApi.Resources
import JsonApi exposing (Document, Resource)
import Components.Transaction as Transaction


decodeDocument : Json.Decoder Document
decodeDocument =
    JsonApi.Decode.document


decodeTransactions : Document -> List Transaction.Model
decodeTransactions document =
    case JsonApi.Documents.primaryResourceCollection document of
        Err error ->
            Debug.crash error

        Ok deliveries ->
            List.map decodeTransactionAttributes deliveries


decodeTransactionAttributes : Resource -> Transaction.Model
decodeTransactionAttributes resource =
    case JsonApi.Resources.attributes transactionDecoder resource of
        Err error ->
            Debug.crash error

        Ok transaction ->
            transaction


transactionDecoder : Json.Decoder Transaction.Model
transactionDecoder =
    Json.map5 Transaction.Model
        (Json.field "inserted-at" Json.string)
        (Json.field "value-date" Json.string)
        (Json.field "description" Json.string)
        (Json.field "amount" Json.string)
        (Json.field "balance" Json.string)
