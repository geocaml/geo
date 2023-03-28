open Owl_base_dense_ndarray_d

type t = arr

let pp ppf (t : t) = Owl_pretty.pp_dsnda ppf t
let equal t1 t2 = equal t1 t2
let x t = get t [| 0 |]
let y t = get t [| 1 |]

type orient = Counterclockwise | Clockwise | Collinear

let pp_orient ppf = function
  | Counterclockwise -> Fmt.pf ppf "counterclockwise"
  | Clockwise -> Fmt.pf ppf "clockwise"
  | Collinear -> Fmt.pf ppf "collinear"

let orient coord1 coord2 coord3 =
  let c1x, c1y = (x coord1, y coord1) in
  let c2x, c2y = (x coord2, y coord2) in
  let c3x, c3y = (x coord3, y coord3) in
  (* Cross product essentially *)
  let comp =
    Float.compare
      (((c2x -. c1x) *. (c3y -. c1y)) -. ((c2y -. c1y) *. (c3x -. c1x)))
      0.
  in
  if comp < 0 then Clockwise
  else if comp > 0 then Counterclockwise
  else Collinear

let euclid_distance c1 c2 =
  let diff = sub c2 c1 |> abs in
  Float.sqrt (Float.pow (x diff) 2. +. Float.pow (y diff) 2.)

let create_point ~x ~y =
  let arr = zeros [| 2 |] in
  set arr [| 0 |] x;
  set arr [| 1 |] y;
  arr

let create ~x ~y = create_point ~x ~y

let from_length_and_angle ~length ~angle t =
  let adj = Float.cos angle *. length in
  let opp = Float.sin angle *. length in
  let x' = x t in
  let y' = y t in
  create ~x:(x' +. opp) ~y:(y' +. adj)

let to_arr = Fun.id

let of_arr' arr =
  let ndim = Owl_base_dense_ndarray_generic.num_dims arr in
  if ndim <> 1 then invalid_arg "Wrong number of dimensions";
  match Owl_base_dense_ndarray_generic.nth_dim arr 0 with
  | 2 -> create_point ~x:(get arr [| 0 |]) ~y:(get arr [| 1 |])
  | n ->
      invalid_arg
        ("Wrong number of elements, expected 2 or 3 but got " ^ string_of_int n)

let of_arr arr = of_arr' arr

let chaikin_smoothing _i (t1, t2) =
  let p_ix = x t1 and p_iy = y t1 in
  let p_jx = x t2 and p_jy = y t2 in
  let q =
    create
      ~x:((0.75 *. p_ix) +. (0.25 *. p_jx))
      ~y:((0.75 *. p_iy) +. (0.25 *. p_jy))
  in
  let r =
    create
      ~x:((0.25 *. p_ix) +. (0.75 *. p_jx))
      ~y:((0.25 *. p_iy) +. (0.75 *. p_jy))
  in
  (q, r)

let slope coord1 coord2 =
  let diff = sub coord2 coord1 in
  y diff /. x diff

let angle coord1 coord2 coord3 =
  let m1 = slope coord2 coord1 in
  let m2 = slope coord2 coord3 in
  Float.atan2 (Float.abs (m2 -. m1)) (1. +. (m2 *. m1))

let azimuth coord1 coord2 =
  let lng_a = x coord1 in
  let lat_a = y coord1 in
  let lng_b = x coord2 in
  let lat_b = y coord2 in
  let delta_lng = lng_a -. lng_b in
  let s = Float.cos lat_b *. Float.sin delta_lng in
  let c =
    Float.cos lat_a
    -. Float.cos lat_b
    -. (Float.sin lat_a *. Float.cos lat_b *. Float.cos delta_lng)
  in
  Float.atan2 s c
