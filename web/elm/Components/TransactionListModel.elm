module Components.TransactionListModel exposing (..)

import Http
import JsonApi exposing (Document)
import Components.Transaction as Transaction


type alias Model =
    { transactions : List Transaction.Model
    , userId : String
    , fetchAll : Bool
    , fetching : Bool
    }


initialModel : String -> Model
initialModel userId =
    { transactions = []
    , userId = userId
    , fetchAll = False
    , fetching = False
    }


type Msg
    = Fetch
    | FetchResult (Result Http.Error Document)
