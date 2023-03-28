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

let mid t =
  let min_x, min_y = (fst t.min, snd t.min) in
  let max_x, max_y = (fst t.max, snd t.max) in
  Coord.create ~x:((min_x +. max_x) /. 2.) ~y:((min_y +. max_y) /. 2.)

let lines t =
  let min_x, min_y = (fst t.min, snd t.min) in
  let max_x, max_y = (fst t.max, snd t.max) in
  let coord1 = Coord.create ~x:min_x ~y:min_y in
  let coord2 = Coord.create ~x:max_x ~y:min_y in
  let coord3 = Coord.create ~x:max_x ~y:max_y in
  let coord4 = Coord.create ~x:min_x ~y:max_y in
  [| coord1; coord2; coord3; coord4 |]
