module CustomMdl exposing (..)

import AutoExpand
import Html exposing (Html, div, node)
import Html.Attributes exposing (href, rel)
import Material
import Material.Options as Options
import Material.Textfield as Textfield


type Msg
    = AutoExpandInput { textValue : String, state : AutoExpand.State }
    | Mdl (Material.Msg Msg)


type alias Model =
    { value : String
    , state : AutoExpand.State
    , mdl : Material.Model
    }


init : ( Model, Cmd Msg )
init =
    ( { state = AutoExpand.initState config
      , value = ""
      , mdl = Material.model
      }
    , Cmd.none
    )


config : AutoExpand.Config Msg
config =
    AutoExpand.config
        { onInput = AutoExpandInput
        , padding = 10
        , lineHeight = 20
        , minRows = 1
        , maxRows = 4
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AutoExpandInput { state, textValue } ->
            ( { model
                | state = state
                , value = textValue
              }
            , Cmd.none
            )

        Mdl mdlMsg ->
            Material.update Mdl mdlMsg model


view : Model -> Html Msg
view model =
    div []
        [ node "link" [ rel "stylesheet", href "https://code.getmdl.io/1.3.0/material.indigo-pink.min.css" ] []
        , Textfield.render
            Mdl
            [ 9 ]
            model.mdl
            ([ Textfield.label "Multiline with 6 rows"
             , Textfield.floatingLabel
             , Textfield.textarea
             , Textfield.value model.value
             ]
                ++ List.map Options.attribute (AutoExpand.attributes config model.state model.value)
            )
            []
        ]


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , init = init
        }
