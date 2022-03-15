module Floatarr = Owl_base_dense_ndarray_d

let arr = Alcotest.testable Owl_pretty.pp_dsnda Floatarr.equal

module Test_prim = struct
  let creation () =
    let point = Geo.Point.create ~lng:3.0 ~lat:3.0 () in
    let point_arr = Geo.Point.to_arr point in
    let expect = Floatarr.create [| 2 |] 3.0 in
    Alcotest.(check arr "same ndarray" point_arr expect)

  let multipoints () =
    let p1 = Geo.Point.create ~lng:1.0 ~lat:3.0 () in
    let p2 = Geo.Point.create ~lng:2.0 ~lat:3.0 () in
    let p3 = Geo.Point.create ~lng:3.0 ~lat:3.0 () in
    let mp = Geo.Multipoint.of_points [| p1; p2; p3 |] in
    let mp' = Geo.Multipoint.to_points mp |> Geo.Multipoint.of_points in
    Alcotest.(
      check arr "same multipoints" (Geo.Multipoint.to_arr mp)
        (Geo.Multipoint.to_arr mp'))

  let tests =
    [
      Alcotest.test_case "point" `Quick creation;
      Alcotest.test_case "multipoints" `Quick multipoints;
    ]
end

module Algos = struct
  open Geo

  let centroid () =
    let point = Geo.Point.create ~lng:3.0 ~lat:3.0 () in
    Algo.centroid point
end

let () = Alcotest.run "geo" [ ("primitives", Test_prim.tests) ]
