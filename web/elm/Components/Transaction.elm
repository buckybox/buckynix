module Components.Transaction exposing (view, Model)

import Html exposing (..)
import Html.Attributes exposing (..)
import Lib.HtmlAttributesExtra exposing (innerHtml)
import Lib.DateExtra as DateExtra


type alias Model =
    { creationDate : String
    , valueDate : String
    , description : String
    , amount : String
    , balance : String
    }


view : Model -> Html a
view model =
    tr []
        [ td [] [ text <| format model.creationDate ]
        , td [] [ text <| format model.valueDate ]
        , td [] [ text model.description ]
        , td [ class "text-right", innerHtml model.amount ] []
        , td [ class "text-right", innerHtml model.balance ] []
        ]


format : String -> String
format string =
    DateExtra.unsafeFromString string |> DateExtra.toISOString
