module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import AutoExpand


{-| Make a message for the AutoExpand updates.

Note how it has a record with two fields:
- `textValue`, the current inputted text in the textarea
- `state`, the new internal state for the AutoExpand

-}
type Msg
    = AutoExpandInput { textValue : String, state : AutoExpand.State }


{-| Configuration for AutoExpand. Do not put this in your model.
-}
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


{-| Our model holds the `AutoExpand.State` and serves as the source of truth for
the current text inputted in the textarea.
-}
type alias Model =
    { autoexpand : AutoExpand.State
    , inputText : String
    }


{-| The initial state for the AutoExpand needs the `Config`.
-}
init : ( Model, Cmd Msg )
init =
    ( { autoexpand = AutoExpand.initState config
      , inputText = ""
      }
    , Cmd.none
    )


{-| In update, be sure to update both the AutoExpand state and the inputted
text value.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AutoExpandInput { state, textValue } ->
            ( { model
                | autoexpand = state
                , inputText = textValue
              }
            , Cmd.none
            )


{-| AutoExpand's view takes in the `Config`, the `State` and the current text
value.
-}
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
