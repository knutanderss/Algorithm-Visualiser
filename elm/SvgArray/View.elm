module SvgArray.View exposing (..)

import Html
import Array
import Html.Attributes as HtmlAttr
import Html.Events exposing (onClick)
import Svg
import Svg.Attributes exposing (..)
import Types exposing (..)
import Animation


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Svg.svg
            [
              "0 0 " ++ svgWidth model ++ " 150"
              |> viewBox
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


svgWidth : Model -> String
svgWidth model =
    (boxSize + boxSpace)
        * (Array.length model.array)
        - boxSpace
        |> Basics.max 0
        |> toString


intBox : Element -> Html.Html Msg
intBox e =
    Svg.g (Animation.render e.position)
        [ Svg.rect [ x "0", y "0", width (toString boxSize), height (toString boxSize), rx "15", ry "15", fill (statusToColor e.status) ] []
        , Svg.rect [ x "5", y "5", width "70", height "70", rx "10", ry "10", fill "#fff" ] []
        , Svg.text_ [ x "40", y "57", textAnchor "middle", fontSize "50px" ] [ Svg.text (toString (e.value)) ]
        ]


statusToColor : ElementStatus -> String
statusToColor status =
    case status of
        Normal ->
            "#000"

        LookedAt ->
            "#2EA336"


boxSize : Int
boxSize =
    80


boxSpace : Int
boxSpace =
    15
