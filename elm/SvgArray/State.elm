module SvgArray.State exposing (..)


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
            (case model.playing of
                False ->
                    { model | playing = True }
                        ! [ delayAndStepNext ]

                True ->
                    { model | playing = False }
                        ! []
            )

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

        Animate index animMsg ->
            { model
                | array =
                    AE.getUnsafe index model.array
                        |> updatePosition animMsg
                        |> (\e -> A.set index e model.array)
            }
                ! []


step : ArrayAnimation -> Model -> Model
step animation model =
    case animation of
        Exchange a b ->
            { model
                | array = stepExchange a b model.array
            }

        LookAt i ->
            { model
                | array = setStatusInArray LookedAt i model.array
            }

        UnlookAt i ->
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


intBox : Element -> Html Msg
intBox e =
    g (Animation.render e.position)
        [ rect [ x "0", y "0", width "100", height "100", rx "15", ry "15", fill (statusToColor e.status) ] []
        , rect [ x "5", y "5", width "90", height "90", rx "10", ry "10", fill "#fff" ] []
        , text_ [ x "50", y "73", textAnchor "middle", fontSize "70px" ] [ Svg.text (toString (e.value)) ]
        ]


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
    , steps = animToSteps <| sort defaultArray
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
        List.map4 Element numbers indices styles colorList
            |> A.fromList



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    (A.length model.array)
        - 1
        |> List.range 0
        |> List.map (\i -> Animation.subscription (Animate i) [ (AE.getUnsafe i model.array).position ])
        |> batch
