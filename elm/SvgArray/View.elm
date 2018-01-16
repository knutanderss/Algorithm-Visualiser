module SvgArray.View exposing (..)


view : Model -> Html Msg
view model =
    Html.div []
        [ svg
            [ SvgAttr.width "1000"
            , SvgAttr.height "150"
            ]
            (model.array
                |> Array.toList
                |> List.map intBox
            )
        , Html.div [ HtmlAttr.class "buttons" ]
            [ Html.button [ onClick StartClicked ]
                [ Html.text
                    (if model.playing then
                        "Stop"
                     else
                        "Start"
                    )
                ]
            , Html.button [ HtmlAttr.class "blue-button", onClick StepBackward ] [ Html.text "<<" ]
            , Html.button [ HtmlAttr.class "blue-button", onClick StepForward ] [ Html.text ">>" ]
            ]
        ]
