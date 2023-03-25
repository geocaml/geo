open Owl_base_dense_ndarray_d

type t = arr Array.t

let pp ppf (t : t) = Fmt.array Owl_pretty.pp_dsnda ppf t
let exterior_ring t = t.(0)

let interior_rings t =
  let l = Array.length t in
  if l > 0 then Array.sub t 1 (l - 1) else [||]

let intersects t1 t2 =
  let e1 = exterior_ring t1 in
  let e2 = exterior_ring t2 in
  LineString.intersects e1 e2

let rings t = t
let create t = t
let chaikin_smoothing _i t = t
