module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (placeholder)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Array as A
import Process
import Time exposing (Time)
import Task
import Debug
import Array.Extra as AE
import Sort exposing (..)
import Animation
import Platform.Sub exposing (batch)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { array : A.Array Element
    , steps : List ArrayAnimation
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


getPosition : Element -> Animation.State
getPosition e =
    e.position


updatePosition : Animation.Msg -> Element -> Element
updatePosition msg element =
    { element | position = Animation.update msg element.position }


defaultArray =
    [ 88, 8, 36, 11, 13, 17, 82, 47 ]


init : ( Model, Cmd Msg )
init =
    { array = constructArray <| defaultArray
    , steps = Debug.log "steps: " <| animToSteps <| sort defaultArray
    , playing = False
    }
        ! []



-- UPDATE


type Msg
    = NextStep
    | StartClicked
    | TestClicked
    | Animate Int Animation.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NextStep ->
            case Debug.log "" <| model.steps of
                [] ->
                    model ! []

                (Exchange a b) :: xs ->
                    { model
                        | array = stepExchange a b model.array
                        , steps = xs
                    }
                        ! if model.playing then
                            [ delayAndStepNext ]
                          else
                            []

                (LookAt i) :: xs ->
                    { model
                        | array = setStatusInArray LookedAt i model.array
                        , steps = xs
                    }
                        ! if model.playing then
                            [ delayAndStepNext ]
                          else
                            []

                (UnlookAt i) :: xs ->
                    { model
                        | array = setStatusInArray Normal i model.array
                        , steps = xs
                    }
                        ! if model.playing then
                            [ delayAndStepNext ]
                          else
                            []

        StartClicked ->
            -- TODO: Don't start if already started
            { model
                | playing = not model.playing
            }
                ! [ delayAndStepNext ]

        TestClicked ->
            model ! []

        Animate index animMsg ->
            { model
                | array =
                    AE.getUnsafe index model.array
                        |> updatePosition animMsg
                        |> (\e -> A.set index e model.array)
            }
                ! []


statusToColor : ElementStatus -> String
statusToColor status =
    case status of
        Normal ->
            "#000"

        LookedAt ->
            "#2EA336"


second ( _, a ) =
    a


setStatusInArray : ElementStatus -> Int -> A.Array Element -> A.Array Element
setStatusInArray status index array =
    AE.getUnsafe index array
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
        |> \e -> A.set index e array


delayAndStepNext =
    delay (Time.millisecond * 800) NextStep


delay : Time -> msg -> Cmd msg
delay time msg =
    Process.sleep time
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity


stepExchange : Int -> Int -> A.Array Element -> A.Array Element
stepExchange i1 i2 array =
    let
        e1 =
            AE.getUnsafe i1 array

        e2 =
            AE.getUnsafe i2 array
    in
        { e2 | index = i1 }
            |> updatePositionAnimation
            |> (\e -> A.set i1 e array)
            |> ({ e1 | index = i2 }
                    |> updatePositionAnimation
                    |> \e -> A.set i2 e
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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    (A.length model.array)
        - 1
        |> List.range 0
        |> List.map (\i -> Animation.subscription (Animate i) [ (AE.getUnsafe i model.array).position ])
        |> batch



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ svg
            [ width "1000"
            , height "150"
            ]
            (model.array
                |> A.toList
                |> List.map intBox
            )
        , div [ class "buttons" ]
            [ button [ onClick StartClicked ]
                [ Html.text
                    (if model.playing then
                        "Stop"
                     else
                        "Start"
                    )
                ]
            , button [ onClick TestClicked ] [ Html.text "Test" ]
            ]
        ]


intBox : Element -> Html Msg
intBox e =
    g (Animation.render e.position)
        [ rect [ x "0", y "0", width "100", height "100", rx "15", ry "15", fill (statusToColor e.status) ] []
        , rect [ x "5", y "5", width "90", height "90", rx "10", ry "10", fill "#fff" ] []
        , text_ [ x "50", y "73", textAnchor "middle", fontSize "70px" ] [ Svg.text (toString (e.value)) ]
        ]


constructArray : List Int -> A.Array Element
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
        List.map4 Element numbers indices (second (Debug.log "styles" ( List.length styles, styles ))) colorList
            |> A.fromList


calculateX : Int -> Int
calculateX =
    ((*) 120)


calculateY : ElementStatus -> Int
calculateY status =
    case status of
        Normal ->
            0

        LookedAt ->
            30
