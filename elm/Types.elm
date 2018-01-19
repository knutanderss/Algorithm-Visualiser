module Types exposing (..)

import Array
import Animation
import SvgArray.Types exposing (ArrayAnimation, Animator)


type Msg
    = NextStep
    | StartClicked
    | StepBackward
    | StepForward
    | Animate Int Animation.Msg
    | ArrayGenerated SortingAlgorithm (List Int)


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
    | CurrentElement
    | ComparedWith


type alias SortingAlgorithm =
    List Int -> Animator (Array.Array Int) ArrayAnimation
