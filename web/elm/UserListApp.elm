port module UserListApp exposing (..)

import Html exposing (Html, div)
import Html.App
import Components.UserList as UserList


type alias Model =
    { userListModel : UserList.Model }


init : ( Model, Cmd Msg )
init =
    ( { userListModel = UserList.initialModel }, Cmd.none )


type Msg
    = UserListMsg UserList.Msg
    | JsMsg (List String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserListMsg userListMsg ->
            let
                ( updatedModel, cmd ) =
                    UserList.update userListMsg model.userListModel
            in
                ( { model | userListModel = updatedModel }, Cmd.map UserListMsg cmd )

        JsMsg [ "UserList.Fetch" ] ->
            let
                ( updatedModel, cmd ) =
                    UserList.update UserList.Fetch model.userListModel
            in
                ( { model | userListModel = updatedModel }, Cmd.map UserListMsg cmd )

        JsMsg [ "UserList.Search", query ] ->
            let
                ( updatedModel, cmd ) =
                    UserList.update (UserList.Search query) model.userListModel
            in
                ( { model | userListModel = updatedModel }, Cmd.map UserListMsg cmd )

        JsMsg _ ->
            ( model, Cmd.none )


userListView : Model -> Html Msg
userListView model =
    Html.App.map UserListMsg (UserList.view model.userListModel)


view : Model -> Html Msg
view model =
    div [] [ userListView model ]


subscriptions : Model -> Sub Msg
subscriptions model =
    jsEvents JsMsg



-- port for listening for events from JavaScript


port jsEvents : (List String -> msg) -> Sub msg


main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
