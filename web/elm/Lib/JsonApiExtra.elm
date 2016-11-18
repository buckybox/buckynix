module Lib.JsonApiExtra exposing (get, post)

import Http
import Json.Decode
import Task exposing (Task)


get : Json.Decode.Decoder a -> String -> Task Http.Error a
get decoder url =
    Http.send Http.defaultSettings
        { verb = "GET"
        , headers = headers
        , url = url
        , body = Http.empty
        }
        |> Http.fromJson decoder


post : Json.Decode.Decoder a -> String -> String -> Task Http.Error a
post decoder url body =
    Http.send Http.defaultSettings
        { verb = "POST"
        , headers = headers
        , url = url
        , body = Http.string body
        }
        |> Http.fromJson decoder


headers : List ( String, String )
headers =
    [ ( "Accept", "application/vnd.api+json" )
    , ( "Content-Type", "application/vnd.api+json" )
    ]
