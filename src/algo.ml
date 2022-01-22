open Prim

let centroid : [ point | position ] t -> float = function
  | Point _ | Position _ -> 1.
