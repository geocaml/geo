type t = { min : float * float; max : float * float }

let create_pairs (x1, y1) (x2, y2) =
  let lx, ly = (min x1 x2, min y1 y2) in
  let rx, ry = (max x1 x2, max y1 y2) in
  { min = (lx, ly); max = (rx, ry) }

let create coord1 coord2 =
  let p1 = (Coord.x coord1, Coord.y coord1) in
  let p2 = (Coord.x coord2, Coord.y coord2) in
  create_pairs p1 p2

let left t = fst t.min
let bottom t = snd t.min
let right t = fst t.max
let top t = snd t.max

let intersect a b =
  left a < right b && right a > left b && top a > bottom b && bottom a < top b

let min t = Coord.create ~x:(fst t.min) ~y:(snd t.min)
let max t = Coord.create ~x:(fst t.max) ~y:(snd t.max)

let pp ppf t =
  Fmt.pf ppf "min:%a max:%a"
    Fmt.(pair float float)
    t.min
    Fmt.(pair float float)
    t.max

let equal t1 t2 = t1.min = t2.min && t1.max = t2.max
