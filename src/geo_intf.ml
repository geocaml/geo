open Owl_base_dense_ndarray_d
module G = Owl_base_dense_ndarray_generic

module type Conv = sig
  type t

  val to_arr : t -> arr
  val of_arr : arr -> t
end

module type Intf = sig
  module Position : sig
    type t
    (** A position - a longitude and latitude with an optional altitude *)

    val lng : t -> float
    (** The longitude value of the position *)

    val lat : t -> float
    (** The latitude value of the position *)

    val alt : t -> float option
    (** Optional altitude/elevation value of the position *)

    val create : ?alt:float -> lng:float -> lat:float -> unit -> t
    (** A position constructor *)

    include Conv with type t := t
  end

  module Point : sig
    type t
    (** A point is a single {!Position.t} *)

    val to_position : t -> Position.t
    (** Convert a point to a position *)

    val create : Position.t -> t
    (** Create a point from a position. *)

    include Conv with type t := t
  end

  module MultiPoint : sig
    type t
    (** A multipoint is an array of positions. *)

    val coordinates : t -> Position.t array
    (** Get the positions that make up this multipoint object. *)

    val create : Position.t array -> t
    (** Create a multipoint object from an array of positions. *)

    include Conv with type t := t
  end

  module LineString : sig
    type t
    (** A line string is two or more points *)

    val coordinates : t -> Position.t array
    (** Convert the line into a position array *)

    val create : Position.t array -> t
    (** Create a line string from positions, will raise [Invalid_argument] if
        the array doesn't have at least two positions. *)

    include Conv with type t := t
  end

  module MultiLineString : sig
    type t
    (** A collection of line strings *)

    val lines : t -> LineString.t array
    (** Access the lines *)

    val create : LineString.t array -> t
    (** Create a multiline string *)

    include Conv with type t := t
  end

  module Polygon : sig
    type t
    (** A close loop with optional rings *)

    val interior_rings : t -> LineString.t array
    val exterior_ring : t -> LineString.t

    val create : LineString.t array -> t
    (** Create a polygon object from an array of close line strings (note no
        checking is down here to ensure the loops are indeed closed.) *)

    include Conv with type t := t
  end

  module MultiPolygon : sig
    type t
    (** A multi-polygon object *)

    val polygons : t -> Polygon.t array
    (** Access the polygons *)

    val create : Polygon.t array -> t
    (** Create a multi-polygon object from an array of {!Polygon.t}s *)

    include Conv with type t := t
  end

  type t =
    | Point of Point.t
    | MultiPoint of MultiPoint.t
    | LineString of LineString.t
    | MultiLineString of MultiLineString.t
    | Polygon of Polygon.t
    | MultiPolygon of MultiPolygon.t
    | Collection of t list
end
