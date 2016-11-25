port module LoginApp exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (Error)
import Json.Decode
import Json.Encode
import JsonApi.Decode
import JsonApi.Documents
import JsonApi.Resources
import JsonApi exposing (Document, Resource)
import Lib.JsonApiExtra as JsonApiExtra


port reloadWindow : String -> Cmd msg


type Msg
    = Input FieldId String
    | LogIn
    | LogInResult (Result Http.Error Document)


type FieldId
    = Email
    | Password


type alias Model =
    { email : Field
    , password : Field
    , userId : String
    , loading : Bool
    }


type alias Field =
    { value : String
    , visible : Bool
    , error : Maybe String
    }


initialField : Field
initialField =
    { value = ""
    , visible = False
    , error = Nothing
    }


initialModel : Model
initialModel =
    { email = initialField
    , password = initialField
    , userId = ""
    , loading = False
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input id value ->
            let
                fieldVisibility id =
                    case id of
                        Email ->
                            model.email.visible

                        Password ->
                            model.password.visible

                newField id =
                    { value = value, error = Nothing, visible = fieldVisibility id }

                newModel =
                    case id of
                        Email ->
                            { model | email = newField Email }

                        Password ->
                            { model | password = newField Password }
            in
                ( newModel, Cmd.none )

        LogIn ->
            ( { model | loading = True }, signIn model.email.value model.password.value )

        LogInResult (Ok document) ->
            let
                userId =
                    decodeSession document

                showPasswordField =
                    not (String.isEmpty model.email.value) && String.isEmpty userId

                passwordField =
                    model.password

                newPasswordField =
                    { passwordField | visible = showPasswordField }

                reload =
                    if String.isEmpty userId then
                        Cmd.none
                    else
                        reloadWindow ""
            in
                ( { model
                    | userId = userId
                    , password = newPasswordField
                    , loading = (reload /= Cmd.none)
                  }
                , reload
                )

        LogInResult (Err _) ->
            ( { model | loading = False }, Cmd.none )


request : Json.Encode.Value -> String -> Cmd Msg
request body url =
    JsonApiExtra.post url body LogInResult decodeDocument


signIn : String -> String -> Cmd Msg
signIn email password =
    let
        attributes =
            Json.Encode.object
                [ ( "email", Json.Encode.string email )
                , ( "password", Json.Encode.string password )
                ]

        body =
            Json.Encode.object
                [ ( "data"
                  , Json.Encode.object
                        [ ( "type", Json.Encode.string "session" )
                        , ( "attributes", attributes )
                        ]
                  )
                ]
    in
        "/api/sessions" |> request body


decodeDocument : Json.Decode.Decoder Document
decodeDocument =
    JsonApi.Decode.document


decodeSession : Document -> String
decodeSession document =
    case JsonApi.Documents.primaryResource document of
        Err error ->
            Debug.crash error

        Ok session ->
            decodeSesionAttributes session


decodeSesionAttributes : Resource -> String
decodeSesionAttributes session =
    JsonApi.Resources.attributes (Json.Decode.field "user-id" Json.Decode.string) session
        |> Result.toMaybe
        |> Maybe.withDefault ""


view : Model -> Html Msg
view model =
    Html.form [ onSubmit LogIn ] <|
        List.concat
            [ emailInput
            , passwordInput model.password
            , buttons model
            ]


emailInput : List (Html Msg)
emailInput =
    [ div [ class "form-group" ]
        [ label [] [ text "Please enter your email below" ]
        , input
            [ onInput (Input Email)
            , name "email"
            , placeholder "Email"
            , type_ "email"
            , class "form-control"
            , required True
            ]
            []
        ]
    ]


passwordInput : Field -> List (Html Msg)
passwordInput field =
    let
        labelAndInput =
            showIf field.visible
                [ label [] [ text "Please enter your password below" ]
                , input
                    [ onInput (Input Password)
                    , name "password"
                    , placeholder "Password"
                    , type_ "password"
                    , class "form-control"
                    , required True
                    ]
                    []
                ]

        error =
            case field.error of
                Just error ->
                    [ span [ class "help-block" ] [ text error ] ]

                Nothing ->
                    []
    in
        [ div [ class "form-group" ] <| List.concat [ labelAndInput, error ] ]


buttons : Model -> List (Html Msg)
buttons model =
    [ div [ class "form-group text-xs-center" ] <|
        List.concat
            [ submitButton model.loading
            , showIf model.password.visible noPasswordButton
            ]
    ]


submitButton : Bool -> List (Html Msg)
submitButton isDisabled =
    [ input
        [ type_ "submit"
        , class <|
            "btn btn-primary"
                ++ if isDisabled then
                    " fa-spin"
                   else
                    ""
        , disabled isDisabled
        , value <|
            if isDisabled then
                "..."
            else
                "Submit"
        ]
        []
    ]


noPasswordButton : List (Html Msg)
noPasswordButton =
    [ a
        [ class "btn btn-secondary ml-3", href "#" ]
        [ text "Don't know your password?" ]
    ]


showIf : Bool -> List (Html Msg) -> List (Html Msg)
showIf condition html =
    if condition then
        html
    else
        []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
