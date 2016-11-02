module Components.JsonApi exposing (..)

import Http

get decoder url =
  let
    request =
      Http.send Http.defaultSettings
        { verb = "GET"
        , headers = [("Accept", "application/vnd.api+json")]
        , url = url
        , body = Http.empty
        }
  in
    Http.fromJson decoder request
