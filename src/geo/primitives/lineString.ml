open Owl_base_dense_ndarray_d
module Arr = Owl_base_dense_ndarray_d

type t = arr

let pp ppf (t : t) = Owl_pretty.pp_dsnda ppf t

let coordinates t =
  let num_points = Owl_base_dense_ndarray_generic.nth_dim t 0 in
  split (Array.init num_points (fun _ -> 1)) t
  |> Array.map (fun v -> reshape v [| 2 |])

let create t =
  let arr_arr = Array.map Coord.to_arr t in
  Owl_base_dense_ndarray_d.of_rows arr_arr

let to_arr = Fun.id
let of_arr = Fun.id

let bounding_box t =
  let maxs = Arr.max ~axis:0 ~keep_dims:false t in
  let mins = Arr.min ~axis:0 ~keep_dims:false t in
  let min_x = Arr.get mins [| 0 |] in
  let min_y = Arr.get mins [| 1 |] in
  let max_x = Arr.get maxs [| 0 |] in
  let max_y = Arr.get maxs [| 1 |] in
  Rect.create_pairs (min_x, min_y) (max_x, max_y)

let intersect_segment (start_coord1, end_coord1) (start_coord2, end_coord2) =
  let orient1_1 = Coord.orient start_coord1 end_coord1 start_coord2 in
  let orient1_2 = Coord.orient start_coord1 end_coord1 end_coord2 in
  let orient2_1 = Coord.orient start_coord2 end_coord2 start_coord1 in
  let orient2_2 = Coord.orient start_coord2 end_coord2 end_coord1 in
  match (orient1_1, orient1_2, orient2_1, orient2_2) with
  | Coord.Collinear, Collinear, Collinear, Collinear -> false
  | _ ->
      Fmt.pr "%a %a %a %a" Coord.pp_orient orient1_1 Coord.pp_orient orient1_2
        Coord.pp_orient orient2_1 Coord.pp_orient orient2_1;
      let b = orient1_1 <> orient1_2 && orient2_1 <> orient2_2 in
      Fmt.pr "This case %b %b" (orient1_1 <> orient1_2) b;
      b

let intersects l1 l2 =
  let coords1 = coordinates l1 in
  let coords2 = coordinates l2 in
  let intersects = ref [] in
  for i = 0 to Array.length coords1 - 2 do
    for j = 0 to Array.length coords2 - 2 do
      let segment1 = (coords1.(i), coords1.(i + 1)) in
      let segment2 = (coords2.(j), coords2.(j + 1)) in
      let intersect = intersect_segment segment1 segment2 in
      if intersect then intersects := (segment1, segment2) :: !intersects
      else ()
    done
  done;
  List.rev !intersects

let smooth_linestring t =
  let c = coordinates t in
  let l = Array.length c in
  let closed = Coord.equal c.(0) c.(l - 1) in
  let new_length =
    if closed then (Array.length c * 2) - 1 else Array.length c * 2
  in
  let arr' = Owl_base_dense_ndarray_d.zeros [| new_length; 2 |] in
  let j = if closed then ref 0 else ref 1 in
  for i = 0 to l - 2 do
    let q, r = Coord.chaikin_smoothing 0 (c.(i), c.(i + 1)) in
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
