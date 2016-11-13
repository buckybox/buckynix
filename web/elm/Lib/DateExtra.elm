module Lib.DateExtra exposing (..)

import Date exposing (Date)

unsafeFromString : String -> Date
unsafeFromString string =
  case Date.fromString string of
      Ok date -> date
      Err msg -> Debug.crash("unsafeFromString")
