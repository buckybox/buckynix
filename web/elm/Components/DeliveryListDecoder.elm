module Components.DeliveryListDecoder exposing (decodeDocument, decodeDeliveries)

import Dict exposing (Dict)
import Json.Decode as Json exposing ((:=))

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
    Err error -> Debug.crash error
    Ok deliveries -> List.map makeTuple deliveries |> Dict.fromList

makeTuple : Resource -> (UUID, Delivery.Model)
makeTuple resource =
  let
    delivery = decodeDeliveriesAttributes resource
  in
    (delivery.id, delivery)

decodeDeliveriesAttributes : Resource -> Delivery.Model
decodeDeliveriesAttributes resource =
  case JsonApi.Resources.attributes deliveryDecoder resource of
    Err error -> Debug.crash error
    Ok delivery -> { delivery | user = (decodeRelatedUser resource) }

deliveryDecoder : Json.Decoder Delivery.Model
deliveryDecoder =
  Json.object5 Delivery.Model
    ("id" := Json.string)
    ("date" := Json.string)
    (Json.succeed "ADDRESS") -- FIXME
    (Json.succeed "PRODUCT") -- FIXME
    (Json.succeed User.emptyModel)

decodeRelatedUser : Resource -> User.Model
decodeRelatedUser delivery =
  case JsonApi.Resources.relatedResource "user" delivery of
    Err error -> Debug.crash error
    Ok user -> decodeUserAttributes user

decodeUserAttributes : Resource -> User.Model
decodeUserAttributes user =
  case JsonApi.Resources.attributes userDecoder user of
    Err error -> User.emptyModel -- XXX: when user relationship isn't included
    Ok user -> user

userDecoder : Json.Decoder User.Model
userDecoder =
  Json.object4 User.Model
    (Json.succeed "URL") -- url
    ("name" := Json.string)
    (Json.succeed "") -- balance
    (Json.succeed []) -- tags
    -- ("tags" := Json.list Json.string)
