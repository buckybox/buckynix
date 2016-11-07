module DeliveryListApp exposing (..)

import Html exposing (Html, div)
import Html.App
import Task exposing (Task)
import Collage exposing (Form)
import Color exposing (Color)
import Element exposing (Element)

type alias Model =
  { forms: List Form }

initialModel : Model
initialModel =
  { forms =
      [Collage.rect 30 60 |> Collage.filled (Color.rgb 255 0 0)]
  }

init : (Model, Cmd Action)
init =
  (initialModel, Task.perform (always Init) (always Init) (Task.succeed 0))

type Action
  = Init

update : Action -> Model -> (Model, Cmd Action)
update msg model =
  case msg of
    Init ->
      (model, Cmd.none)

view : Model -> Html Action
view model =
  div [] [ renderView model ]

renderView : Model -> Html Action
renderView model =
  Collage.collage 600 600 model.forms |> Element.toHtml

subscriptions : Model -> Sub Action
subscriptions model =
  Sub.none

main : Program Never
main =
  Html.App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
