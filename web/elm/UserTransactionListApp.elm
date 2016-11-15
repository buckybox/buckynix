module UserTransactionListApp exposing (..)

import Html exposing (Html, div)
import Html.App
import Components.UserTransactionList as UserTransactionList


type alias Flags =
    { userId : String }


type alias Model =
    { userTransactionListModel : UserTransactionList.Model }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { userTransactionListModel = UserTransactionList.initialModel (flags.userId) }, Cmd.none )


type Msg
    = UserTransactionListMsg UserTransactionList.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserTransactionListMsg userTransactionListMsg ->
            let
                ( updatedModel, cmd ) =
                    UserTransactionList.update userTransactionListMsg model.userTransactionListModel
            in
                ( { model | userTransactionListModel = updatedModel }, Cmd.map UserTransactionListMsg cmd )


userTransactionListView : Model -> Html Msg
userTransactionListView model =
    Html.App.map UserTransactionListMsg (UserTransactionList.view model.userTransactionListModel)


view : Model -> Html Msg
view model =
    div [] [ userTransactionListView model ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Flags
main =
    Html.App.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
