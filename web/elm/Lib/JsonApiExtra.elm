module Lib.JsonApiExtra exposing (..)

import Http


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
