open Owl_base_dense_ndarray_d

type t = arr Array.t

let exterior_ring t = t.(0)

let interior_rings t =
  let l = Array.length t in
  if l > 0 then Array.sub t 1 (l - 1) else [||]

let rings t = t
let create t = t
let chaikin_smoothing _i t = t
