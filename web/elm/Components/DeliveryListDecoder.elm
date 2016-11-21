module Components.DeliveryListDecoder exposing (decodeDocument, decodeDeliveries)

import Dict exposing (Dict)
import Json.Decode as Json
import JsonApi.Decode
import JsonApi.Documents
import JsonApi.Resources
import JsonApi exposing (Document, Resource)
import Lib.UUID exposing (UUID)
import Components.Delivery as Delivery
import Components.User as User


decodeDocument : Json.Decoder Document
decodeDocument =
    JsonApi.Decode.document


decodeDeliveries : Document -> Dict UUID Delivery.Model
decodeDeliveries document =
    case JsonApi.Documents.primaryResourceCollection document of
        Err error ->
            Debug.crash error

        Ok deliveries ->
            List.map makeTuple deliveries |> Dict.fromList


makeTuple : Resource -> ( UUID, Delivery.Model )
makeTuple resource =
    let
        delivery =
            decodeDeliveriesAttributes resource
    in
        ( delivery.id, delivery )


decodeDeliveriesAttributes : Resource -> Delivery.Model
decodeDeliveriesAttributes resource =
    case JsonApi.Resources.attributes deliveryDecoder resource of
        Err error ->
            Debug.crash error

        Ok delivery ->
            { delivery | user = (decodeRelatedUser resource) }


deliveryDecoder : Json.Decoder Delivery.Model
deliveryDecoder =
    Json.map5 Delivery.Model
        (Json.field "id" Json.string)
        (Json.field "date" Json.string)
        (Json.field "address" Json.string)
        (Json.succeed "PRODUCT NAME")
        -- FIXME
        (Json.succeed User.emptyModel)


decodeRelatedUser : Resource -> User.Model
decodeRelatedUser delivery =
    case JsonApi.Resources.relatedResource "user" delivery of
        Err error ->
            Debug.crash error

        Ok user ->
            decodeUserAttributes user


decodeUserAttributes : Resource -> User.Model
decodeUserAttributes user =
    case JsonApi.Resources.attributes userDecoder user of
        Err error ->
            -- XXX: when user relationship isn't included
            User.emptyModel

        Ok user ->
            user


userDecoder : Json.Decoder User.Model
userDecoder =
    Json.map4 User.Model
        (Json.succeed "URL")
        (Json.field "name" Json.string)
        (Json.succeed "")
        (Json.succeed [])
