type t = Polygon.t Array.t

let pp ppf (t : t) = Fmt.array Polygon.pp ppf t
let polygons t = t
let create t = t
let to_arr = Fun.id
let of_arr = Fun.id
