module InsertionSort exposing (..)

import Html
import State
import View
import Types exposing (Model, Msg)
import Sort.InsertionSort


main : Program Never Model Msg
main =
    Html.program
        { init = State.init Sort.InsertionSort.sort
        , view = View.view
        , update = State.update
        , subscriptions = State.subscriptions
        }
