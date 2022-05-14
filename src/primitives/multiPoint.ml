open Owl_base_dense_ndarray_d

type t = arr

let coordinates t =
  let num_points = Owl_base_dense_ndarray_generic.nth_dim t 0 in
  Utils.sub_ndarray (Array.init num_points (fun _ -> 1)) t
  |> Array.map (fun v -> reshape v [| 2 |])

let create t =
  let arr_arr = Array.map Coordinate.to_arr t in
  Owl_base_dense_ndarray_d.of_rows arr_arr

let to_arr = Fun.id
let of_arr = Fun.id
