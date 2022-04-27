module type Centroidable = sig
  type t

  val centroid : t -> float
end
