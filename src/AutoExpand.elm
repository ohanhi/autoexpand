module AutoExpand
    exposing
        ( Config
        , State
        , attributes
        , config
        , initState
        , view
        , withClass
        , withId
        , withPlaceholder
        , withStyles
        )

{-| This library lets you use automatically expanding textareas in Elm.
This means the textarea grows in height until it reaches the maximum number of
rows allowed and then becomes a scrollable box.


# View

@docs view


# Configuration

@docs Config, config, withId, withClass, withPlaceholder, withStyles


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
    , styles : List ( String, String )
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
        , styles = []
        , placeholder = Nothing
        , id = Nothing
        , class = Nothing
        }


{-| Add inline styles for the textarea.

    myConfig
        |> withStyles [ ( "font-family", "sans-serif" ) ]

-}
withStyles : List ( String, String ) -> Config msg -> Config msg
withStyles styles (Config configInternal) =
    Config { configInternal | styles = styles }


{-| Add the `placeholder` attribute to the configuration.

    myConfig
        |> withPlaceholder "Type a message here"

-}
withPlaceholder : String -> Config msg -> Config msg
withPlaceholder string (Config configInternal) =
    Config { configInternal | placeholder = Just string }


{-| Add the `id` attribute to the configuration.

    myConfig
        |> withId "chat-message-textarea"

-}
withId : String -> Config msg -> Config msg
withId string (Config configInternal) =
    Config { configInternal | id = Just string }


{-| Add the `class` attribute to the configuration.

    myConfig
        |> withClass "textarea has-inset-shadow"

-}
withClass : String -> Config msg -> Config msg
withClass string (Config configInternal) =
    Config { configInternal | class = Just string }


{-| Sets up the initial `State` for the textarea using a `Config`.
-}
initState : Config msg -> State
initState (Config config) =
    State config.minRows


{-| Show the textarea on your page.

    view : Model -> Html Msg
    view model =
        AutoExpand.view config model.autoExpandState model.textValue

-}
view : Config msg -> State -> String -> Html msg
view config state textValue =
    textarea (attributes config state textValue) []


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
attributes (Config config) (State rowCount) textValue =
    mapToList Html.Attributes.placeholder config.placeholder
        ++ mapToList Html.Attributes.id config.id
        ++ mapToList Html.Attributes.class config.class
        ++ [ on "input" (inputDecoder config)
           , rows rowCount
           , Html.Attributes.value textValue
           , textareaStyles config rowCount
           ]


getRows : ConfigInternal msg -> Int -> Int
getRows config scrollHeight =
    ((toFloat scrollHeight - 2 * config.padding) / config.lineHeight)
        |> ceiling
        |> clamp config.minRows config.maxRows


inputDecoder : ConfigInternal msg -> Decoder msg
inputDecoder config =
    map2 (\t s -> config.onInput { textValue = t, state = s })
        (at [ "target", "value" ] string)
        (at [ "target", "scrollHeight" ] int
            |> map (State << getRows config)
        )


textareaStyles : ConfigInternal msg -> Int -> Html.Attribute msg
textareaStyles config rowCount =
    config.styles
        ++ [ ( "padding", toString config.padding ++ "px" )
           , ( "box-sizing", "border-box" )
           , ( "line-height", toString config.lineHeight ++ "px" )
           , ( "overflow"
             , if rowCount <= config.maxRows then
                "visible"
               else
                "scroll-y"
             )
           ]
        |> style


mapToList : (a -> b) -> Maybe a -> List b
mapToList f =
    Maybe.map (\a -> [ a ])
        >> Maybe.withDefault []
        >> List.map f
