open Geo
module Floatarr = Owl_base_dense_ndarray_d

let arr = Alcotest.testable Owl_pretty.pp_dsnda Floatarr.equal

module Test_prim = struct
  let creation () =
    let point = Point.create @@ Position.create ~lng:3.0 ~lat:3.0 () in
    let point_arr = Point.to_arr point in
    let expect = Floatarr.create [| 2 |] 3.0 in
    Alcotest.(check arr "same ndarray" point_arr expect)

  let multipoints () =
    let p1 = Position.create ~lng:1.0 ~lat:3.0 () in
    let p2 = Position.create ~lng:2.0 ~lat:3.0 () in
    let p3 = Position.create ~lng:3.0 ~lat:3.0 () in
    let mp = MultiPoint.create [| p1; p2; p3 |] in
    let mp' = MultiPoint.coordinates mp |> MultiPoint.create in
    Alcotest.(
      check arr "same multipoints" (MultiPoint.to_arr mp) (MultiPoint.to_arr mp));
    Alcotest.(
      check arr "same multipoints" (MultiPoint.to_arr mp)
        (MultiPoint.to_arr mp'))

  let linestring () =
    let p1 = Position.create ~lng:1.0 ~lat:3.0 () in
    let p2 = Position.create ~lng:2.0 ~lat:3.0 () in
    let p3 = Position.create ~lng:3.0 ~lat:3.0 () in
    let mp = LineString.create [| p1; p2; p3 |] in
    let mp' = LineString.coordinates mp |> LineString.create in
    Alcotest.(
      check arr "same linestring" (LineString.to_arr mp) (LineString.to_arr mp));
    Alcotest.(
      check arr "same linestring" (LineString.to_arr mp) (LineString.to_arr mp'))

  let polygons () =
    let p1 = Position.create ~lng:1.0 ~lat:3.0 () in
    let p2 = Position.create ~lng:2.0 ~lat:3.0 () in
    let p3 = Position.create ~lng:3.0 ~lat:3.0 () in
    let i_p1 = Position.create ~lng:0.5 ~lat:1.5 () in
    let i_p2 = Position.create ~lng:1.0 ~lat:1.5 () in
    let i_p3 = Position.create ~lng:1.5 ~lat:1.5 () in
    let l1 = LineString.create [| p1; p2; p3; p1 |] in
    let l2 = LineString.create [| i_p1; i_p2; i_p3; i_p1 |] in
    let p = Polygon.create [| l1 |] in
    let p_with_interior = Polygon.create [| l1; l2 |] in
    let irs = Polygon.interior_rings p in
    let er = Polygon.exterior_ring p in
    let p' = Polygon.create (Array.append [| er |] irs) in
    let ip' =
      Polygon.(
        create
          (Array.append
             [| exterior_ring p_with_interior |]
             (interior_rings p_with_interior)))
    in
    Alcotest.(check arr "same polygon" (Polygon.to_arr p) (Polygon.to_arr p'));
    Alcotest.(
      check arr "same exterior 1" (LineString.to_arr l1) (LineString.to_arr er));
    Alcotest.(
      check arr "same exterior 2" (LineString.to_arr l1)
        (LineString.to_arr @@ Polygon.exterior_ring p_with_interior));
    Alcotest.(
      check (array arr) "same interior rings"
        [| LineString.to_arr l2 |]
        (Array.map LineString.to_arr (Polygon.interior_rings p_with_interior)));
    Alcotest.(
      check arr "same polygon (with interior)"
        (Polygon.to_arr p_with_interior)
        (Polygon.to_arr ip'))

  let tests =
    [
      Alcotest.test_case "point" `Quick creation;
      Alcotest.test_case "multipoints" `Quick multipoints;
      Alcotest.test_case "linestring" `Quick linestring;
      Alcotest.test_case "polygon" `Quick polygons;
    ]
end

module Algos = struct
  (* open Geo *)

  (* let centroid () =
     let point = Po.create ~lng:3.0 ~lat:3.0 () in
     Algo.centroid point *)
end

let () = Alcotest.run "geo" [ ("primitives", Test_prim.tests) ]
