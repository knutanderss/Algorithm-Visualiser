module InsertionSort exposing (..)

import Html
import State
import View
import Types exposing (Model, Msg)


main : Program Never Model Msg
main =
    Html.program
        { init = State.init
        , view = View.view
        , update = State.update
        , subscriptions = State.subscriptions
        }
