module App exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Html.App

import Components.CustomerList as CustomerList

type alias Model =
  { customerListModel: CustomerList.Model }

initialModel : Model
initialModel =
  { customerListModel = CustomerList.initialModel }

init : (Model, Cmd Msg)
init =
  ( initialModel, Cmd.none )

type Msg
  = CustomerListMsg CustomerList.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    CustomerListMsg customerMsg ->
      let (updatedModel, cmd) = CustomerList.update customerMsg model.customerListModel
      in ( { model | customerListModel = updatedModel }, Cmd.map CustomerListMsg cmd )

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

view : Model -> Html Msg
view model =
  div [ class "elm-app" ]
    [ Html.App.map CustomerListMsg (CustomerList.view model.customerListModel) ]

main : Program Never
main =
  Html.App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
