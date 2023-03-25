open Owl_base_dense_ndarray_d

type t = arr Array.t

let pp ppf (t : t) = Fmt.array Owl_pretty.pp_dsnda ppf t
let lines t = t
let create t = t
let to_arr = Fun.id
let of_arr = Fun.id
