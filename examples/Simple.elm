module Main exposing (..)

import AutoExpand exposing (withAttribute)
import Browser
import Html exposing (..)
import Html.Attributes exposing (placeholder, style)


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
        }
        |> withAttribute (style "font-family" "sans-serif")
        |> withAttribute (placeholder "Start writing..")


{-| Our model holds the `AutoExpand.State` and serves as the source of truth for
the current text inputted in the textarea.
-}
type alias Model =
    { autoexpand : AutoExpand.State
    , inputText : String
    }


{-| The initial state for the AutoExpand needs the `Config`.
-}
init : Model
init =
    { autoexpand = AutoExpand.initState config
    , inputText = ""
    }


{-| In update, be sure to update both the AutoExpand state and the inputted
text value.
-}
update : Msg -> Model -> Model
update msg model =
    case msg of
        AutoExpandInput { state, textValue } ->
            { model
                | autoexpand = state
                , inputText = textValue
            }


{-| AutoExpand's view takes in the `Config`, the `State` and the current text
value.
-}
view : Model -> Html Msg
view model =
    div containerStyles
        [ p [] [ text "This textarea will expand as you type until it's 4 rows tall" ]
        , AutoExpand.view config model.autoexpand model.inputText
        ]


containerStyles : List (Html.Attribute msg)
containerStyles =
    [ style "background-color" "rebeccapurple"
    , style "color" "white"
    , style "font-family" "sans-serif"
    , style "width" "100vw"
    , style "height" "100vh"
    , style "display" "flex"
    , style "align-items" "center"
    , style "justify-content" "center"
    , style "flex-direction" "column"
    ]


main : Program () Model Msg
main =
    Browser.sandbox
        { view = view
        , update = update
        , init = init
        }
