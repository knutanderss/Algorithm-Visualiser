module ShellSort exposing (..)

import Html
import State
import View
import Types exposing (..)
import Sort.ShellSort


main : Program Never Model Msg
main =
    Html.program
        { init = State.init Sort.ShellSort.sort
        , view = View.view
        , update = State.update
        , subscriptions = State.subscriptions
        }
