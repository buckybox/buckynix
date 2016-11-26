module Components.UserList exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import List
import Http exposing (Error)
import Json.Decode as Json
import Lib.JsonApiExtra as JsonApiExtra
import Components.User as User


type alias Model =
    { users : List User.Model
    , filter : String
    , nextCount : Int
    , fetching : Bool
    , filterCount : Int
    , totalCount : Int
    }


type alias JsonModel =
    { data : List User.Model
    , filterCount : Int
    , totalCount : Int
    }


type Msg
    = Fetch
    | FetchResult (Result Http.Error JsonModel)
    | Search String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fetch ->
            ( { model | fetching = True }, fetchUsers model )

        FetchResult (Ok jsonModel) ->
            let
                userList =
                    jsonModel.data

                factor =
                    if model.nextCount > List.length (userList) then
                        -- don't grow if no more users
                        1
                    else
                        growthFactor
            in
                ( { model
                    | users = userList
                    , nextCount = model.nextCount * factor
                    , fetching = False
                    , filterCount = jsonModel.filterCount
                    , totalCount = jsonModel.totalCount
                  }
                , Cmd.none
                )

        FetchResult (Err _) ->
            ( { model | fetching = False }, Cmd.none )

        Search filter ->
            let
                updatedModel =
                    { model | filter = filter }
            in
                ( updatedModel, fetchUsers updatedModel )


fetchUsers : Model -> Cmd Msg
fetchUsers model =
    let
        url =
            "/api/users?count="
                ++ (toString model.nextCount)
                ++ "&filter="
                ++ model.filter
    in
        JsonApiExtra.get url FetchResult decodeUserFetch


decodeUserFetch : Json.Decoder JsonModel
decodeUserFetch =
    Json.map3 JsonModel
        (Json.field "data" (Json.list decodeUserData))
        (Json.at [ "meta", "filter-count" ] Json.int)
        (Json.at [ "meta", "total-count" ] Json.int)


decodeUserData : Json.Decoder User.Model
decodeUserData =
    Json.map4 User.Model
        (Json.at [ "links", "self" ] Json.string)
        (Json.at [ "attributes", "name" ] Json.string)
        (Json.at [ "attributes", "balance" ] Json.string)
        (Json.at [ "attributes", "tags" ] (Json.list Json.string))


initialCount : Int
initialCount =
    25



-- we'll fetch X times as many on each fetch (exponential)


growthFactor : Int
growthFactor =
    2


initialModel : Model
initialModel =
    { users = []
    , filter = ""
    , nextCount = initialCount
    , fetching = True
    , filterCount = 0
    , totalCount = 0
    }


view : Model -> Html Msg
view model =
    div [ class "user-list" ]
        [ searchBar model
        , renderUsers model
        ]


renderUsers : Model -> Html Msg
renderUsers model =
    let
        length =
            List.length (model.users)

        moreLinkWrapper =
            if length == 0 || length == model.nextCount // growthFactor then
                -- FIXME
                [ moreLink model.fetching ]
            else
                []

        rows =
            List.map (\user -> User.view user) model.users
    in
        div [ class "row mt-3" ]
            [ div [ class "col-xs" ]
                [ table [ class "table table-striped table-sm" ]
                    [ thead [] [ newLink ]
                    , tbody [] rows
                    , tfoot [] moreLinkWrapper
                    ]
                ]
            ]


searchBar : Model -> Html Msg
searchBar model =
    div [ class "row flex-items-xs-middle" ]
        [ div [ class "col-xs-3" ] []
        , div [ class "col-xs-6" ]
            [ input [ name "filter", placeholder "Search users", class "search form-control", onInput Search, value model.filter ] [] ]
        , div [ class "col-xs-3" ]
            [ small [ class "text-muted" ]
                [ text
                    ((toString model.filterCount)
                        ++ " of "
                        ++ (toString model.totalCount)
                        ++ " matches"
                    )
                ]
            ]
        ]


newLink : Html Msg
newLink =
    tr []
        [ td [ colspan 5 ]
            [ a [ href "/users/new", class "btn btn-outline-warning btn-block" ] [ text "Create a new user" ] ]
        ]


moreLink : Bool -> Html Msg
moreLink fetching =
    let
        tag =
            if fetching then
                i [ class "fa fa-spinner fa-pulse fa-3x fa-fw" ] []
            else
                a [ href "javascript:void(0)", onClick Fetch ] [ text "more" ]
    in
        tr []
            [ td [ colspan 5, class "text-center" ] [ tag ] ]
