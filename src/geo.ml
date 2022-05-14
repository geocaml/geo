open Owl_base_dense_ndarray_d
include Geo_intf
module Coordinate = Coordinate

module Point = struct
  type t = arr

  let create = Fun.id
  let to_position = Fun.id
  let to_arr = Fun.id
  let of_arr = Fun.id
end

module MultiPoint = MultiPoint
module LineString = LineString
module MultiLineString = MultiLineString
module Polygon = Polygon
module MultiPolygon = MultiPolygon

type t =
  | Point of Point.t
  | MultiPoint of MultiPoint.t
  | LineString of LineString.t
  | MultiLineString of MultiLineString.t
  | Polygon of Polygon.t
  | MultiPolygon of MultiPolygon.t
  | Collection of t list

(* module Algo = Algo *)
