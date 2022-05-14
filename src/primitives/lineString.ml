open Owl_base_dense_ndarray_d

type t = arr

let coordinates t =
  let num_points = Owl_base_dense_ndarray_generic.nth_dim t 0 in
  split (Array.init num_points (fun _ -> 1)) t
  |> Array.map (fun v -> reshape v [| 2 |])

let create t =
  let arr_arr = Array.map Coordinate.to_arr t in
  Owl_base_dense_ndarray_d.of_rows arr_arr

let to_arr = Fun.id
let of_arr = Fun.id

let smooth_linestring t =
  let c = coordinates t in
  let l = Array.length c in
  let closed = Coordinate.equal c.(0) c.(l - 1) in
  let new_length =
    if closed then (Array.length c * 2) - 1 else Array.length c * 2
  in
  let arr' = Owl_base_dense_ndarray_d.zeros [| new_length; 2 |] in
  let j = if closed then ref 0 else ref 1 in
  for i = 0 to l - 2 do
    let q, r = Coordinate.chaikin_smoothing 0 (c.(i), c.(i + 1)) in
    set_slice [ [ !j ]; [] ] arr' q;
    set_slice [ [ !j + 1 ]; [] ] arr' r;
    j := !j + 2
  done;
  (* For closed line strings we preserve the fact that they are closed. *)
  if not closed then (
    set_slice [ [ 0 ]; [] ] arr' c.(0);
    set_slice [ [ new_length - 1 ]; [] ] arr' c.(l - 1))
  else set_slice [ [ new_length - 1 ]; [] ] arr' (get_slice [ [ 0 ]; [] ] arr');
  arr'

let chaikin_smoothing i t =
  if i = 0 then copy t
  else
    let rec smoothen t = function
      | 0 -> t
      | j -> smoothen (smooth_linestring t) (j - 1)
    in
    smoothen t i
