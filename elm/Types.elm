module Types exposing (..)

import Array
import Animation
import Svg.ArrayTypes exposing (ArrayAnimation)


type Msg
    = NextStep
    | StartClicked
    | StepBackward
    | StepForward
    | Animate Int Animation.Msg


type alias Model =
    { array : Array.Array Element
    , steps : List ArrayAnimation
    , history : List ArrayAnimation
    , playing : Bool
    }


type alias Element =
    { value : Int
    , index : Int
    , position : Animation.State
    , status : ElementStatus
    }


type ElementStatus
    = Normal
    | LookedAt
