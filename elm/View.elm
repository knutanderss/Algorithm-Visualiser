module View exposing (..)

import SvgArray.View
import Types exposing (..)
import Html


view : Model -> Html.Html Msg
view =
    SvgArray.View.view
