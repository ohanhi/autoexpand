module AutoExpand
    exposing
        ( Config
        , State
        , attributes
        , config
        , initState
        , view
        , withAttribute
        )

{-| This library lets you use automatically expanding textareas in Elm.
This means the textarea grows in height until it reaches the maximum number of
rows allowed and then becomes a scrollable box.


# View

@docs view


# Configuration

@docs Config, config, withAttribute


# State

@docs State, initState


# Custom textareas

@docs attributes

-}

import Html exposing (Html, br, div, p, text, textarea)
import Html.Attributes exposing (rows, style)
import Html.Events exposing (on, onInput)
import Json.Decode exposing (Decoder, at, field, int, map, map2, string)


{-| Keeps track of how many rows we need.
-}
type State
    = State Int


type alias ConfigInternal msg =
    { onInput : { textValue : String, state : State } -> msg
    , padding : Float
    , lineHeight : Float
    , minRows : Int
    , maxRows : Int
    , attributes : List (Html.Attribute msg)
    , placeholder : Maybe String
    , id : Maybe String
    , class : Maybe String
    }


{-| Configuration for your textarea, describing the look and feel.

**Note:** Your `Config` should _never_ be held in your model.
It should only appear in `view` code.

-}
type Config msg
    = Config (ConfigInternal msg)


{-| Create the `Config` for the auto expanding textarea.

A typical configuration might look like this:

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
            }

-}
config :
    { onInput : { textValue : String, state : State } -> msg
    , padding : Float
    , lineHeight : Float
    , minRows : Int
    , maxRows : Int
    }
    -> Config msg
config values =
    Config
        { onInput = values.onInput
        , padding = values.padding
        , lineHeight = values.lineHeight
        , minRows = values.minRows
        , maxRows = values.maxRows
        , attributes = []
        , placeholder = Nothing
        , id = Nothing
        , class = Nothing
        }


{-| Add your own attributes for the textarea.

    myConfig
        |> withAttribute (Html.Attributes.class "chat-textbox")
        |> withAttribute (Html.Attributes.placeholder "jane.dow@example.com")

-}
withAttribute : Html.Attribute msg -> Config msg -> Config msg
withAttribute newAttribute (Config configInternal) =
    Config { configInternal | attributes = newAttribute :: configInternal.attributes }


{-| Sets up the initial `State` for the textarea using a `Config`.
-}
initState : Config msg -> State
initState (Config configInternal) =
    State configInternal.minRows


{-| Show the textarea on your page.

    view : Model -> Html Msg
    view model =
        AutoExpand.view config model.autoExpandState model.textValue

-}
view : Config msg -> State -> String -> Html msg
view conf state textValue =
    textarea (attributes conf state textValue) []


{-| Get the attributes needed for a custom textarea. Note that you may
accidentally break functionality by including some attributes twice.

    textarea
        ([ placeholder "Custom..." ]
            ++ AutoExpand.attributes
                myConfig
                model.autoExpandState
                model.textValue
        )
        []

-}
attributes : Config msg -> State -> String -> List (Html.Attribute msg)
attributes (Config configInternal) (State rowCount) textValue =
    [ on "input" (inputDecoder configInternal)
    , rows rowCount
    , Html.Attributes.value textValue
    ]
        ++ configInternal.attributes
        ++ textareaStyles configInternal rowCount


getRows : ConfigInternal msg -> Int -> Int
getRows configInternal scrollHeight =
    ((toFloat scrollHeight - 2 * configInternal.padding) / configInternal.lineHeight)
        |> ceiling
        |> clamp configInternal.minRows configInternal.maxRows


inputDecoder : ConfigInternal msg -> Decoder msg
inputDecoder configInternal =
    map2 (\t s -> configInternal.onInput { textValue = t, state = s })
        (at [ "target", "value" ] string)
        (at [ "target", "scrollHeight" ] int
            |> map (State << getRows configInternal)
        )


textareaStyles : ConfigInternal msg -> Int -> List (Html.Attribute msg)
textareaStyles configInternal rowCount =
    [ style "padding" (String.fromFloat configInternal.padding ++ "px")
    , style "box-sizing" "border-box"
    , style "line-height" (String.fromFloat configInternal.lineHeight ++ "px")
    , style "overflow"
        (if rowCount <= configInternal.maxRows then
            "visible"

         else
            "scroll-y"
        )
    , style "overflow-x" "hidden"
    ]


mapToList : (a -> b) -> Maybe a -> List b
mapToList f =
    Maybe.map (\a -> [ a ])
        >> Maybe.withDefault []
        >> List.map f
