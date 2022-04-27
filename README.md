geo
---

Geospatial primitives and algorithms in pure OCaml using [Owl](https://github.com/owlbarn/owl). This library acts as a basis for all other libraries that need geospatial primitives as part of the [geocaml organisation](https://github.com/geocaml).

```ocaml
# open Geo;;
# let p1 = Position.create ~lat:1.0 ~lng:2.0 ();;
val p1 : Position.t = <abstr>
# let p2 = Position.create ~lat:2.0 ~lng:2.0 ();;
val p2 : Position.t = <abstr>
# LineString.create [| p1; p2 |] |> LineString.to_arr;;
- : Owl_base_dense_ndarray_d.arr =

   C0 C1
R0  2  1
R1  2  2
```
