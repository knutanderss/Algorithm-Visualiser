module Main exposing (..)

import Html exposing (text)
import Array as A
import Debug


type Animator a
    = Animator ( a, List String )


main =
    text <| toString test


test =
    sort [ 88, 8, 36, 11, 13, 17, 82, 47 ]


listToAnimator : List a -> Animator (A.Array a)
listToAnimator list =
    Animator ( A.fromList list, [] )


animToList : Animator (A.Array a) -> List a
animToList (Animator ( array, steps )) =
    A.toList array


sort : List Int -> Animator (A.Array Int)
sort =
    sort_ 1 << listToAnimator


sort_ : Int -> Animator (A.Array Int) -> Animator (A.Array Int)
sort_ index ((Animator ( array, steps )) as animator) =
    if index < A.length array then
        let
            animUpdated =
                Animator ( array, steps ++ [ "Now at index " ++ (toString index) ] )
                    |> moveBack index
        in
            sort_ (index + 1) animUpdated
    else
        Animator ( array, steps ++ [ "Finished." ] )


moveBack : Int -> Animator (A.Array Int) -> Animator (A.Array Int)
moveBack i ((Animator ( array, steps )) as animator) =
    if i - 1 < 0 then
        animator
    else
        let
            currentElem =
                -- This is ugly, but the alternative (afaik) is even worse
                Maybe.withDefault 0 <| A.get i array

            exchElem =
                Maybe.withDefault 0 <| A.get (i - 1) array
        in
            if currentElem < exchElem then
                steps
                    ++ [ "Exchanging element " ++ (toString i) ++ " with " ++ (toString <| i - 1) ]
                    |> ((,) (exchange i currentElem (i - 1) exchElem array))
                    |> Animator
                    |> moveBack (i - 1)
            else
                animator


exchange : Int -> a -> Int -> a -> A.Array a -> A.Array a
exchange i1 e1 i2 e2 array =
    A.set i1 e2 <| A.set i2 e1 array
