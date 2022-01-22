open Owl_base_dense_ndarray_d
module G = Owl_base_dense_ndarray_generic

type position = [ `position ]
type point = [ `point ]
type multipoint = [ `multipoint ]

type _ t =
  | Point : arr -> [> point ] t
  | Position : arr -> [> position ] t
  | Multipoint : arr -> [> multipoint ] t

module type Conv = sig
  type t

  val of_arr : Owl_base_dense_ndarray_d.arr -> t
  val to_arr : t -> Owl_base_dense_ndarray_d.arr
end

module Position = struct
  let lng : position t -> elt = fun (Position t) -> get t [| 0 |]
  let lat : position t -> elt = fun (Position t) -> get t [| 1 |]

  let alt : position t -> elt option =
   fun (Position t) ->
    try Some (get t [| 2 |]) with Invalid_argument _ -> None

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

  let create ?alt ~lng ~lat () = Position (create_point ?alt ~lng ~lat ())
  let to_arr : [< position ] t -> arr = fun (Position t) -> t

  let _of_arr arr =
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

  let of_arr arr = Position (_of_arr arr)
end

module Point = struct
  let create ?alt ~lng ~lat () = Point (Position.create_point ?alt ~lng ~lat ())
  let to_position : point t -> position t = fun (Point arr) -> Position arr
  let to_arr : point t -> arr = fun (Point arr) -> arr
  let of_arr arr = Point (Position._of_arr arr)
end

module Multipoint = struct
  let to_points : multipoint t -> point t array =
   fun (Multipoint t) ->
    let num_points = G.nth_dim t 0 in
    Array.map (fun arr -> Point arr) @@ Utils.sub_ndarray [| num_points |] t

  let of_points : point t array -> multipoint t =
   fun t ->
    let arr_arr = Array.map Point.to_arr t in
    Multipoint (Owl_base_dense_ndarray_d.of_rows arr_arr)

  let to_arr : multipoint t -> arr = fun (Multipoint arr) -> arr
  let of_arr arr = Multipoint arr
end
