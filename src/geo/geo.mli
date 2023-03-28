open Owl_base_dense_ndarray_d
(* module G = Owl_base_dense_ndarray_generic *)

module type Conv = sig
  type t

  val to_arr : t -> arr
  val of_arr : arr -> t
end

(** {1 Algorithms}

    Various geo-spatial algorithms. *)

(** {2 Bearings}

    The bearing is the {e horizontal angle} between the direction on an object
    and north (or sometimes another object). Different assumptions are made when
    calculating different bearings (e.g. using geodesics). *)

(** {1 Primitives}

    Geo-primitives such as coordinates and polygons. *)

module Coord : sig
  type t
  (** A two-dimensional coordinate *)

  val x : t -> float
  (** The first coordinate *)

  val y : t -> float
  (** The second coordinate *)

  val create : x:float -> y:float -> t
  (** A coordinate constructor *)

  val from_length_and_angle : length:float -> angle:float -> t -> t
  (** [from_length_and_angle ~length ~angle t] create a new coordinate that is
      [length] away from [t] at an azimuth angle [angle]. *)

  val pp : t Fmt.t [@@ocaml.toplevel_printer]
  (** A pretty printer *)

  val equal : t -> t -> bool

  include Conv with type t := t
  include Algo_intf.Chaikin_smoothing with type t := t * t

  type orient = Counterclockwise | Clockwise | Collinear

  val pp_orient : orient Fmt.t

  val orient : t -> t -> t -> orient
  (** The two-dimensional orientation of three points. *)

  val euclid_distance : t -> t -> float
  (** Euclidean distance between two points. *)

  val azimuth : t -> t -> float
  (** [azimuth a b] uses the {e haversine} formula to calculate the initial
      bearing between two points where we interpret the [(x, y)] as longitude
      and latitude. *)
end

module Point : sig
  type t
  (** A point is a single {!Coord.t} *)

  val to_position : t -> Coord.t
  (** Convert a point to a position *)

  val create : Coord.t -> t
  (** Create a point from a position. *)

  val pp : t Fmt.t [@@ocaml.toplevel_printer]
  (** A pretty printer *)

  include Conv with type t := t
end

module Rect : sig
  type t
  (** A specialised {! Polygon.t}. *)

  val create : Coord.t -> Coord.t -> t
  (** [create coord1 coord2] will create a new rectangle from two corner points. *)

  val intersect : t -> t -> bool
  (** [intersect a b] is true if some part of rectangle [a] intersects some part
      of rectangle [b]. *)

  val min : t -> Coord.t
  (** [min t] returns the lower, left coordinate of the rectangle. *)

  val max : t -> Coord.t
  (** [max t] returns the top, right coordinate of the rectangle. *)

  val lines : t -> Coord.t array
  (** The lines of the rectangle going from the lower-left, counter-clockwise. *)

  val mid : t -> Coord.t
  (** The mid-point of the rectangle. *)

  val pp : t Fmt.t [@@ocaml.toplevel_printer]
  (** A pretty printer *)

  val equal : t -> t -> bool
end

module MultiPoint : sig
  type t
  (** A multipoint is an array of positions. *)

  val coordinates : t -> Coord.t array
  (** Get the positions that make up this multipoint object. *)

  val create : Coord.t array -> t
  (** Create a multipoint object from an array of positions. *)

  val pp : t Fmt.t [@@ocaml.toplevel_printer]
  (** A pretty printer *)

  include Conv with type t := t
end

module LineString : sig
  type t
  (** A line string is two or more points *)

  val coordinates : t -> Coord.t array
  (** Convert the line into a position array *)

  val create : Coord.t array -> t
  (** Create a line string from positions, will raise [Invalid_argument] if the
      array doesn't have at least two positions. *)

  val pp : t Fmt.t [@@ocaml.toplevel_printer]
  (** A pretty printer *)

  include Conv with type t := t
  include Algo_intf.Chaikin_smoothing with type t := t

  val bounding_box : t -> Rect.t
  (** The bounding box of the linestring. *)

  val intersects : t -> t -> ((Coord.t * Coord.t) * (Coord.t * Coord.t)) list
  (** [intersects l1 l2] looks to see if linestring [l1] intersects with
      linestring [l2]. Linestrings may intersect multiple times. The result is a
      list of all of the line segments where an intersection occurs. If the list
      is empty then [l1] and [l2] do not intersect. *)
end

module MultiLineString : sig
  type t
  (** A collection of line strings *)

  val lines : t -> LineString.t array
  (** Access the lines *)

  val create : LineString.t array -> t
  (** Create a multiline string *)

  val pp : t Fmt.t [@@ocaml.toplevel_printer]
  (** A pretty printer *)
end

module Polygon : sig
  type t
  (** A close loop with optional rings *)

  val interior_rings : t -> LineString.t array
  val exterior_ring : t -> LineString.t
  val rings : t -> LineString.t array

  val create : LineString.t array -> t
  (** Create a polygon object from an array of close line strings (note no
      checking is down here to ensure the loops are indeed closed.) *)

  val pp : t Fmt.t [@@ocaml.toplevel_printer]
  (** A pretty printer *)

  include Algo_intf.Chaikin_smoothing with type t := t

  val intersects : t -> t -> ((Coord.t * Coord.t) * (Coord.t * Coord.t)) list
  (** Similar to {! LineString.intersects} only for the exterior ring of two
      polygons.*)
end

module MultiPolygon : sig
  type t
  (** A multi-polygon object *)

  val polygons : t -> Polygon.t array
  (** Access the polygons *)

  val create : Polygon.t array -> t
  (** Create a multi-polygon object from an array of {!Polygon.t}s *)

  val pp : t Fmt.t [@@ocaml.toplevel_printer]
  (** A pretty printer *)
end

type t =
  | Point of Point.t
  | MultiPoint of MultiPoint.t
  | LineString of LineString.t
  | MultiLineString of MultiLineString.t
  | Polygon of Polygon.t
  | Rect of Rect.t
  | MultiPolygon of MultiPolygon.t
  | Collection of t list
