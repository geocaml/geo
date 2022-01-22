open Owl_base_dense_ndarray_d
module G = Owl_base_dense_ndarray_generic

type position = [ `position ]
type point = [ `point ]
type multipoint = [ `multipoint ]

type _ t = private
  | Point : arr -> [> point ] t
  | Position : arr -> [> position ] t
  | Multipoint : arr -> [> multipoint ] t
      (** The type for primitives distinguished with a phantom type but all
          represented identically. *)

module type Conv = sig
  type t

  val of_arr : Owl_base_dense_ndarray_d.arr -> t
  (** Construct a {!t} from an array.

      @raise [Invalid_arg]
        if the array is not suitable (e.g. too many dimensions) *)

  val to_arr : t -> Owl_base_dense_ndarray_d.arr
  (** Convert a {!t} to an array, this will always succeed. *)
end

module Position : sig
  val create : ?alt:float -> lng:float -> lat:float -> unit -> position t
  (** [create ?alt ~lng ~lat ()] creates a new position with the given longitude
      and latitude. Optionally it will have an altitude. *)

  val lng : position t -> float
  (** Get the longitude of a position. *)

  val lat : position t -> float
  (** Get the latitiude of a position. *)

  val alt : position t -> float option
  (** Get the altitude of a position if it has one. *)

  include Conv with type t := position t
end

module Point : sig
  val create : ?alt:float -> lng:float -> lat:float -> unit -> point t
  (** [create ?alt ~lng ~lat ()] creates a new position with the given longitude
      and latitude. Optionally it will have an altitude. *)

  val to_position : point t -> position t
  (** Convert a point to a position. *)

  include Conv with type t := point t
end

module Multipoint : sig
  val to_points : multipoint t -> point t array
  val of_points : point t array -> multipoint t

  include Conv with type t := multipoint t
end
