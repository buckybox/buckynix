module Lib.HtmlAttributesExtra exposing (..)

import Html exposing (Attribute)
import Json.Encode exposing (string)
import VirtualDom exposing (property)


innerHtml : String -> Attribute msg
innerHtml =
    VirtualDom.property "innerHTML" << Json.Encode.string
