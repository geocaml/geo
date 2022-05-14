module type Centroid = sig
  type t

  val centroid : t -> float
end

module type Chaikin_smoothing = sig
  type t

  val chaikin_smoothing : int -> t -> t
  (** Use the chaikin smoothing algorithm to smoothen a geometry. The [int]
      decides the number of iterations.
      {{:http://www.idav.ucdavis.edu/education/CAGDNotes/Chaikins-Algorithm/Chaikins-Algorithm.html}
      See this explanation of the smoothing algorithm}. *)
end
