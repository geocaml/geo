open Owl_base_dense_ndarray_d
module Coord = Coord

module type Conv = sig
  type t

  val to_arr : t -> arr
  val of_arr : arr -> t
end

module Point = struct
  type t = arr

  let pp ppf (t : t) = Owl_pretty.pp_dsnda ppf t
  let create = Fun.id
  let to_position = Fun.id
  let to_arr = Fun.id
  let of_arr = Fun.id
end

module MultiPoint = MultiPoint
module LineString = LineString
module MultiLineString = MultiLineString
module Polygon = Polygon
module Rect = Rect
module MultiPolygon = MultiPolygon

type t =
  | Point of Point.t
  | MultiPoint of MultiPoint.t
  | LineString of LineString.t
  | MultiLineString of MultiLineString.t
  | Polygon of Polygon.t
  | Rect of Rect.t
  | MultiPolygon of MultiPolygon.t
  | Collection of t list
