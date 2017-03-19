module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import AutoExpand


type Msg
    = AutoExpandInput { textValue : String, state : AutoExpand.State }


config : AutoExpand.Config Msg
config =
    AutoExpand.config
        { onInput = AutoExpandInput
        , padding = 10
        , lineHeight = 20
        , minRows = 1
        , maxRows = 4
        , styles = []
        }


type alias Model =
    { autoexpand : AutoExpand.State
    , inputText : String
    }


init : ( Model, Cmd Msg )
init =
    ( { autoexpand = AutoExpand.initState config
      , inputText = ""
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AutoExpandInput { state, textValue } ->
            ( { autoexpand = state, inputText = textValue }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ containerStyle ]
        [ AutoExpand.view config model.autoexpand model.inputText
        ]


containerStyle : Html.Attribute msg
containerStyle =
    style
        [ ( "background-color", "rebeccapurple" )
        , ( "color", "white" )
        , ( "font-family", "sans-serif" )
        , ( "width", "100vw" )
        , ( "height", "100vh" )
        , ( "display", "flex" )
        , ( "align-items", "center" )
        , ( "justify-content", "center" )
        , ( "flex-direction", "column" )
        ]


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , init = init
        }
