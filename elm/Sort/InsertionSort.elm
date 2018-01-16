module InsertionSort exposing (sort, animToSteps, Animator(..), ArrayAnimation(..))

import Array as A
import Array.Extra as AE
import Svg.ArrayAnimation exposing (..)


sort : List Int -> Animator (A.Array Int) ArrayAnimation
sort =
    sort_ 1 << listToAnimator


sort_ : Int -> Animator (A.Array Int) ArrayAnimation -> Animator (A.Array Int) ArrayAnimation
sort_ index ((Animator ( array, steps )) as animator) =
    if index < A.length array then
        let
            animUpdated =
                Animator ( array, steps ++ [ LookAt index ] )
                    |> moveBack index
        in
            sort_ (index + 1) animUpdated
    else
        animator


moveBack : Int -> Animator (A.Array Int) ArrayAnimation -> Animator (A.Array Int) ArrayAnimation
moveBack i ((Animator ( array, steps )) as animator) =
    if i - 1 < 0 then
        unlook i animator
    else
        let
            currentElem =
                AE.getUnsafe i array

            exchElem =
                AE.getUnsafe (i - 1) array
        in
            if currentElem < exchElem then
                steps
                    ++ [ Exchange i (i - 1) ]
                    |> ((,) (exchange i currentElem (i - 1) exchElem array))
                    |> Animator
                    |> moveBack (i - 1)
            else
                unlook i animator


unlook : Int -> Animator a ArrayAnimation -> Animator a ArrayAnimation
unlook i (Animator ( array, steps )) =
    Animator ( array, steps ++ [ UnlookAt i ] )


listToAnimator : List a -> Animator (A.Array a) ArrayAnimation
listToAnimator list =
    Animator ( A.fromList list, [] )


animToList : Animator (A.Array a) ArrayAnimation -> List a
animToList (Animator ( array, steps )) =
    A.toList array


animToSteps : Animator a ArrayAnimation -> List ArrayAnimation
animToSteps (Animator ( _, steps )) =
    steps


exchange : Int -> a -> Int -> a -> A.Array a -> A.Array a
exchange i1 e1 i2 e2 array =
    A.set i1 e2 <| A.set i2 e1 array
