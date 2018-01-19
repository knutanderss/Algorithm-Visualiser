module Sort.InsertionSort exposing (sort)

import Array
import Array.Extra as ArrayExtra
import SvgArray.Types exposing (..)
import Sort.Common exposing (..)


sort : List Int -> Animator (Array.Array Int) ArrayAnimation
sort =
    sort_ 1 << listToAnimator


sort_ : Int -> Animator (Array.Array Int) ArrayAnimation -> Animator (Array.Array Int) ArrayAnimation
sort_ index ((Animator ( array, steps )) as animator) =
    if index < Array.length array then
        let
            animUpdated =
                Animator ( array, steps ++ [ LookAt index ] )
                    |> moveBack index
        in
            sort_ (index + 1) animUpdated
    else
        animator


moveBack : Int -> Animator (Array.Array Int) ArrayAnimation -> Animator (Array.Array Int) ArrayAnimation
moveBack i ((Animator ( array, steps )) as animator) =
    if i - 1 < 0 then
        unlook i animator
    else
        let
            currentElem =
                ArrayExtra.getUnsafe i array

            exchElem =
                ArrayExtra.getUnsafe (i - 1) array
        in
            if currentElem < exchElem then
                steps
                    ++ [ Exchange i (i - 1) ]
                    |> ((,) (exchange i currentElem (i - 1) exchElem array))
                    |> Animator
                    |> moveBack (i - 1)
            else
                unlook i animator
