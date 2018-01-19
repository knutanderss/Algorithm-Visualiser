module SvgArray.State exposing (..)

import Types exposing (..)
import SvgArray.Types exposing (..)
import SvgArray.View
import Array
import Array.Extra as ArrayExtra
import Animation
import Task
import Process
import Time
import Random


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NextStep ->
            (case model.steps of
                [] ->
                    model

                animation :: xs ->
                    step animation model
                        |> forwardTimeline animation xs
            )
                ! if model.playing then
                    [ delayAndStepNext ]
                  else
                    []

        StartClicked ->
            case model.playing of
                False ->
                    { model | playing = True }
                        ! [ delayAndStepNext ]

                True ->
                    { model | playing = False }
                        ! []

        StepBackward ->
            (case model.history of
                [] ->
                    model

                animation :: xs ->
                    step (flipStep animation) model
                        |> backwardTimeline animation xs
            )
                ! []

        StepForward ->
            case model.steps of
                [] ->
                    model ! []

                animation :: xs ->
                    step animation model
                        |> forwardTimeline animation xs
                        |> flip (!) []

        Types.Animate index animMsg ->
            { model
                | array =
                    ArrayExtra.getUnsafe index model.array
                        |> updatePosition animMsg
                        |> (\e -> Array.set index e model.array)
            }
                ! []

        ArrayGenerated alg list ->
            init_ alg list


step : ArrayAnimation -> Model -> Model
step animation model =
    case animation of
        Exchange a b ->
            { model
                | array = stepExchange a b model.array
            }

        LookAt i ->
            { model
                | array = setStatusInArray CurrentElement i model.array
            }

        UnlookAt i ->
            { model
                | array = setStatusInArray Normal i model.array
            }

        Compare i ->
            { model
                | array = setStatusInArray ComparedWith i model.array
            }

        CompareOff i ->
            { model
                | array = setStatusInArray Normal i model.array
            }


flipStep : ArrayAnimation -> ArrayAnimation
flipStep animation =
    case animation of
        Exchange a b ->
            Exchange b a

        LookAt i ->
            UnlookAt i

        UnlookAt i ->
            LookAt i

        Compare i ->
            CompareOff i

        CompareOff i ->
            Compare i


stepExchange : Int -> Int -> Array.Array Element -> Array.Array Element
stepExchange i1 i2 array =
    let
        e1 =
            ArrayExtra.getUnsafe i1 array

        e2 =
            ArrayExtra.getUnsafe i2 array
    in
        { e2 | index = i1 }
            |> updatePositionAnimation
            |> (\e -> Array.set i1 e array)
            |> ({ e1 | index = i2 }
                    |> updatePositionAnimation
                    |> \e -> Array.set i2 e
               )


updatePositionAnimation : Element -> Element
updatePositionAnimation e =
    { e
        | position =
            let
                x =
                    Animation.px <| toFloat <| calculateX e.index

                y =
                    Animation.px <| toFloat <| calculateY e.status
            in
                Animation.interrupt
                    [ Animation.to [ Animation.translate x y ] ]
                    e.position
    }


calculateX : Int -> Int
calculateX =
    SvgArray.View.boxSize
        + SvgArray.View.boxSpace
        |> (*)


calculateY : ElementStatus -> Int
calculateY status =
    case status of
        Normal ->
            0

        CurrentElement ->
            30

        ComparedWith ->
            0


getPosition : Element -> Animation.State
getPosition e =
    e.position


updatePosition : Animation.Msg -> Element -> Element
updatePosition msg element =
    { element | position = Animation.update msg element.position }


init : SortingAlgorithm -> ( Model, Cmd Msg )
init alg =
    { array = Array.empty
    , steps = []
    , history = []
    , playing = False
    }
        ! (Random.int 0 99
            |> Random.list 15
            |> Random.generate (ArrayGenerated alg)
            |> List.singleton
          )


init_ : SortingAlgorithm -> List Int -> ( Model, Cmd Msg )
init_ sort array =
    { array = constructArray <| array
    , steps = animToSteps <| sort array
    , history = []
    , playing = False
    }
        ! []


forwardTimeline : ArrayAnimation -> List ArrayAnimation -> Model -> Model
forwardTimeline currentAnim rest model =
    { model
        | steps = rest
        , history = currentAnim :: model.history
    }


backwardTimeline : ArrayAnimation -> List ArrayAnimation -> Model -> Model
backwardTimeline currentAnim prevAnims model =
    { model
        | steps = currentAnim :: model.steps
        , history = prevAnims
    }


setStatusInArray : ElementStatus -> Int -> Array.Array Element -> Array.Array Element
setStatusInArray status index array =
    ArrayExtra.getUnsafe index array
        |> (\e ->
                { e
                    | status = status
                    , position =
                        let
                            x =
                                Animation.px <| toFloat <| calculateX index

                            y =
                                Animation.px <| toFloat <| calculateY status
                        in
                            Animation.interrupt
                                [ Animation.to [ Animation.translate x y ] ]
                                e.position
                }
           )
        |> \e -> Array.set index e array


delayAndStepNext : Cmd Msg
delayAndStepNext =
    delay (Time.millisecond * 800) NextStep


delay : Time.Time -> msg -> Cmd msg
delay time msg =
    Process.sleep time
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity


constructArray : List Int -> Array.Array Element
constructArray numbers =
    let
        l =
            List.length numbers

        y =
            Animation.px 0

        indices =
            List.range 0 (l - 1)

        styles =
            indices
                |> List.map (toFloat << calculateX)
                |> List.map Animation.px
                |> List.map (\x -> Animation.translate x y)
                |> List.map List.singleton
                |> List.map Animation.style

        yList =
            List.repeat l 0

        colorList =
            List.repeat l Normal
    in
        List.map4 Element numbers indices styles colorList
            |> Array.fromList


exchange : Int -> a -> Int -> a -> Array.Array a -> Array.Array a
exchange i1 e1 i2 e2 array =
    Array.set i1 e2 <| Array.set i2 e1 array


animToSteps : Animator a ArrayAnimation -> List ArrayAnimation
animToSteps (Animator ( _, steps )) =
    steps



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    (Array.length model.array)
        - 1
        |> List.range 0
        |> List.map (\i -> Animation.subscription (Animate i) [ (ArrayExtra.getUnsafe i model.array).position ])
        |> Sub.batch
