open Owl_base_dense_ndarray_d
include Geo_intf

module Position = struct
  type t = arr

  let lng t = get t [| 0 |]
  let lat t = get t [| 1 |]
  let alt t = try Some (get t [| 2 |]) with Invalid_argument _ -> None

  let create_point ?alt ~lng ~lat () =
    match alt with
    | Some alt ->
        let arr = zeros [| 3 |] in
        set arr [| 0 |] lng;
        set arr [| 1 |] lat;
        set arr [| 2 |] alt;
        arr
    | None ->
        let arr = zeros [| 2 |] in
        set arr [| 0 |] lng;
        set arr [| 1 |] lat;
        arr

  let create ?alt ~lng ~lat () = create_point ?alt ~lng ~lat ()
  let to_arr = Fun.id

  let of_arr' arr =
    let ndim = G.num_dims arr in
    if ndim <> 1 then invalid_arg "Wrong number of dimensions";
    match G.nth_dim arr 0 with
    | 2 -> create_point ~lng:(get arr [| 0 |]) ~lat:(get arr [| 1 |]) ()
    | 3 ->
        create_point
          ~alt:(get arr [| 2 |])
          ~lng:(get arr [| 0 |])
          ~lat:(get arr [| 1 |])
          ()
    | n ->
        invalid_arg
          ("Wrong number of elements, expected 2 or 3 but got "
          ^ string_of_int n)

  let of_arr arr = of_arr' arr
end

module Point = struct
  type t = arr

  let create = Fun.id
  let to_position = Fun.id
  let to_arr = Fun.id
  let of_arr = Fun.id
end

module MultiPoint = struct
  type t = arr

  let coordinates t =
    let num_points = G.nth_dim t 0 in
    Utils.sub_ndarray [| num_points |] t

  let create t =
    let arr_arr = Array.map Point.to_arr t in
    Owl_base_dense_ndarray_d.of_rows arr_arr

  let to_arr = Fun.id
  let of_arr = Fun.id
end

module LineString = struct
  type t = arr

  let coordinates t =
    let num_points = G.nth_dim t 0 in
    Utils.sub_ndarray [| num_points |] t

  let create t =
    let arr_arr = Array.map Point.to_arr t in
    Owl_base_dense_ndarray_d.of_rows arr_arr

  let to_arr = Fun.id
  let of_arr = Fun.id
end

module MultiLineString = struct
  type t = arr

  let lines t =
    let num_points = G.nth_dim t 0 in
    Utils.sub_ndarray [| num_points |] t

  let create t =
    let arr_arr = Array.map Point.to_arr t in
    Owl_base_dense_ndarray_d.of_rows arr_arr

  let to_arr = Fun.id
  let of_arr = Fun.id
end

module Polygon = struct
  type t = arr

  let exterior_ring t = (split [| 1 |] t).(0) |> LineString.of_arr

  let interior_rings t =
    let num_rings = G.nth_dim t 0 in
    print_int num_rings;
    if num_rings > 1 then
      (split [| 1; num_rings - 1 |] t).(1)
      |> MultiLineString.of_arr
      |> MultiLineString.lines
    else [||]

  let create t =
    let arr_arr = Array.map LineString.to_arr t in
    Owl_base_dense_ndarray_d.of_rows arr_arr

  let to_arr = Fun.id
  let of_arr = Fun.id
end

module MultiPolygon = struct
  type t = arr

  let polygons t =
    let num_points = G.nth_dim t 0 in
    Utils.sub_ndarray [| num_points |] t

  let create t =
    let arr_arr = Array.map Point.to_arr t in
    Owl_base_dense_ndarray_d.of_rows arr_arr

  let to_arr = Fun.id
  let of_arr = Fun.id
end

type t =
  | Point of Point.t
  | MultiPoint of MultiPoint.t
  | LineString of LineString.t
  | MultiLineString of MultiLineString.t
  | Polygon of Polygon.t
  | MultiPolygon of MultiPolygon.t
  | Collection of t list

(* module Algo = Algo *)
