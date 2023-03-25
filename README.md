geo
---

Geospatial primitives and algorithms in pure OCaml using [Owl](https://github.com/owlbarn/owl). This library provides some basic geospatial primitives as part of the [geocaml organisation](https://github.com/geocaml).

```ocaml
# open Geo;;
# let p1 = Coord.create ~x:2.0 ~y:1.0;;
val p1 : Coord.t = <abstr>
# let p2 = Coord.create ~x:2.0 ~y:2.0;;
val p2 : Coord.t = <abstr>
# let p3 = Coord.create ~x:3.0 ~y:2.0;;
val p3 : Coord.t = <abstr>
# let l = LineString.create [| p1; p2; p3 |];;
val l : LineString.t = <abstr>
# LineString.chaikin_smoothing 1 l |> Fmt.pr "%a" LineString.pp;;
     C0   C1
R0    2    1
R1    2 1.25
R2    2 1.75
R3 2.25    2
R4 2.75    2
R5    3    2
- : unit = ()
```
