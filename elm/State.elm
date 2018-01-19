module State exposing (..)

import SvgArray.State
import Types exposing (..)


init : SortingAlgorithm -> ( Model, Cmd Msg )
init alg =
    SvgArray.State.init alg


update : Msg -> Model -> ( Model, Cmd Msg )
update =
    SvgArray.State.update


subscriptions : Types.Model -> Sub Types.Msg
subscriptions =
    SvgArray.State.subscriptions
