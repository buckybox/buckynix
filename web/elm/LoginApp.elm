module LoginApp exposing (main)

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


type Msg
    = Input Field String
    | SignIn
    | SignInResult (Result Http.Error Document)


type Field
    = Email
    | Password


type alias Model =
    { credentials : Credentials
    , cookie : String
    , loading : Bool
    }


type alias Credentials =
    { email : String
    , password : String
    }


initialModel : Model
initialModel =
    { credentials = { email = "", password = "" }
    , cookie = ""
    , loading = False
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input name value ->
            let
                oldCredentials =
                    model.credentials

                newCredentials =
                    case name of
                        Email ->
                            { oldCredentials | email = value }

                        Password ->
                            { oldCredentials | password = value }
            in
                ( { model | credentials = newCredentials }, Cmd.none )

        SignIn ->
            ( { model | loading = True }, signIn model.credentials )

        SignInResult (Ok document) ->
            let
                cookie =
                    decodeSession document
            in
                ( { model
                    | cookie = cookie
                    , loading = False
                  }
                , Cmd.none
                )

        SignInResult (Err _) ->
            ( { model | loading = False }, Cmd.none )


request : Json.Encode.Value -> String -> Cmd Msg
request body url =
    JsonApiExtra.post url body SignInResult decodeDocument


signIn : Credentials -> Cmd Msg
signIn credentials =
    let
        attributes =
            Json.Encode.object
                [ ( "email", Json.Encode.string credentials.email )
                , ( "password", Json.Encode.string credentials.password )
                ]

        body =
            Json.Encode.object
                [ ( "data"
                  , Json.Encode.object
                        [ ( "type", Json.Encode.string "sessions" )
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
    JsonApi.Resources.attributes (Json.Decode.field "cookie" Json.Decode.string) session
        |> Result.toMaybe
        |> Maybe.withDefault ""


view : Model -> Html Msg
view model =
    Html.form [ onSubmit SignIn ]
        [ div [ class "form-group" ] [ emailInput ]
        , div [ class "form-group" ] [ passwordInput False ]
        , div [ class "form-group text-xs-center" ] actionButtons
        ]


emailInput : Html Msg
emailInput =
    input
        [ onInput (Input Email)
        , name "email"
        , placeholder "Email"
        , type_ "email"
        , class "form-control"
        , required True
        ]
        []


passwordInput : Bool -> Html Msg
passwordInput visible =
    let
        hiddenClass =
            if visible then
                ""
            else
                "hidden-xs-up"
    in
        input
            [ onInput (Input Password)
            , name "password"
            , placeholder "Password"
            , type_ "password"
            , class ("form-control " ++ hiddenClass)
            , required True
            ]
            []


actionButtons : List (Html Msg)
actionButtons =
    [ input
        [ type_ "submit"
        , value "Submit"
        , class "btn btn-primary"
        ]
        []
    , a [ class "btn btn-secondary ml-3", href "#" ] [ text "Don't know your password?" ]
    ]


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
