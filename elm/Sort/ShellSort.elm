module Sort.ShellSort exposing (sort)

import SvgArray.Types exposing (..)
import Sort.Common exposing (..)
import Array
import Array.Extra as ArrayExtra

jumpStart : Int
jumpStart = 7

sort : List Int -> Animator (Array.Array Int) ArrayAnimation
sort =
    sort_ jumpStart jumpStart << listToAnimator


sort_ : Int -> Int -> Animator (Array.Array Int) ArrayAnimation -> Animator (Array.Array Int) ArrayAnimation
sort_ index jump ((Animator ( array, steps )) as animator) =
    if index < Array.length array then
        let
            animUpdated =
                Animator ( array, steps ++ [ LookAt index ] )
                    |> moveBack index jump
        in
            sort_ (index + 1) jump animUpdated
    else if jump > 1 then
        let 
            newJump = jump // 2
        in
            sort_ newJump newJump animator
    else animator


moveBack : Int -> Int -> Animator (Array.Array Int) ArrayAnimation -> Animator (Array.Array Int) ArrayAnimation
moveBack i jump ((Animator ( array, steps )) as animator) =
    if i - jump < 0 then
        unlook i animator
    else
        let
            currentElem =
                ArrayExtra.getUnsafe i array

            exchElem =
                ArrayExtra.getUnsafe (i - jump) array
        in
            if currentElem < exchElem then
                steps
                    ++ [ Exchange i (i - jump) ]
                    |> ((,) (exchange i currentElem (i - jump) exchElem array))
                    |> Animator
                    |> moveBack (i - jump) jump
            else
                unlook i animator
