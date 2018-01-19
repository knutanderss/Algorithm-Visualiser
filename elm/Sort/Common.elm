module Sort.Common exposing (..)

import Array
import SvgArray.Types exposing (..)


exchange : Int -> a -> Int -> a -> Array.Array a -> Array.Array a
exchange i1 e1 i2 e2 array =
    Array.set i1 e2 <| Array.set i2 e1 array


listToAnimator : List a -> Animator (Array.Array a) ArrayAnimation
listToAnimator list =
    Animator ( Array.fromList list, [] )


unlook : Int -> Animator a ArrayAnimation -> Animator a ArrayAnimation
unlook i (Animator ( array, steps )) =
    Animator ( array, steps ++ [ UnlookAt i ] )


compare : Int -> Animator a ArrayAnimation -> Animator a ArrayAnimation
compare i (Animator ( array, steps )) =
    Animator ( array, steps ++ [ Compare i ] )


compareOff : Int -> Animator a ArrayAnimation -> Animator a ArrayAnimation
compareOff i (Animator ( array, steps )) =
    Animator ( array, steps ++ [ CompareOff i ] )


animToList : Animator (Array.Array a) ArrayAnimation -> List a
animToList (Animator ( array, steps )) =
    Array.toList array
