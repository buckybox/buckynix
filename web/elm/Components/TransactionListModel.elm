module Components.TransactionListModel exposing (..)

import Http
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
    | FetchSucceed JsonModel
    | FetchFail Http.Error


type alias JsonModel =
    { data : List Transaction.Model }
