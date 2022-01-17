open Owl_base_dense_ndarray_d
module G = Owl_base_dense_ndarray_generic

type position = [ `position ]
type point = [ `point ]
type multipoint = [ `multipoint ]
type _ t = arr

module type Conv = sig
  type t

  val of_arr : Owl_base_dense_ndarray_d.arr -> t
  val to_arr : t -> Owl_base_dense_ndarray_d.arr
end

module Position = struct
  let lng t = get t [| 0 |]
  let lat t = get t [| 1 |]
  let alt t = try Some (get t [| 2 |]) with Invalid_argument _ -> None

  let create ?alt ~lng ~lat () =
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

  let to_arr = Fun.id

  let of_arr arr =
    let ndim = G.num_dims arr in
    if ndim <> 1 then invalid_arg "Wrong number of dimensions";
    match G.nth_dim arr 0 with
    | 2 -> create ~lng:(get arr [| 0 |]) ~lat:(get arr [| 1 |]) ()
    | 3 ->
        create
          ~alt:(get arr [| 2 |])
          ~lng:(get arr [| 0 |])
          ~lat:(get arr [| 1 |])
          ()
    | n ->
        invalid_arg
          ("Wrong number of elements, expected 2 or 3 but got "
          ^ string_of_int n)
end

module Point = struct
  let create = Position.create
  let to_position : point t -> position t = Fun.id
  let to_arr : point t -> arr = Fun.id
  let of_arr = Position.of_arr
end

module Multipoint = struct
  let get_points t =
    let _num_points = G.nth_dim t 1 in
    Utils.sub_ndarray [||] t
end
