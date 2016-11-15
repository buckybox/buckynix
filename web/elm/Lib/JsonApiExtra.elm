module Lib.JsonApiExtra exposing (..)

import Http
import Json.Decode
import Task exposing (Task)


get : Json.Decode.Decoder a -> String -> Task Http.Error a
get decoder url =
    Http.send Http.defaultSettings
        { verb = "GET"
        , headers =
            [ ( "Accept", "application/vnd.api+json" )
            , ( "Content-Type", "application/vnd.api+json" )
            ]
        , url = url
        , body = Http.empty
        }
        |> Http.fromJson decoder
