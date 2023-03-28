open Geo
module Floatarr = Owl_base_dense_ndarray_d

let arr = Alcotest.testable Owl_pretty.pp_dsnda Floatarr.equal

module Test_prim = struct
  let creation () =
    let point = Point.create @@ Coord.create ~x:3.0 ~y:3.0 in
    let point_arr = Point.to_arr point in
    let expect = Floatarr.create [| 2 |] 3.0 in
    Alcotest.(check arr "same ndarray" point_arr expect)

  let test_azimuth () =
    let coord1 = Coord.create ~x:0.0 ~y:0.0 in
    let coord2 = Coord.create ~x:(-1.0) ~y:0.0 in
    let azimuth = Coord.azimuth coord1 coord2 in
    Alcotest.(check (float 0.2)) "same azimuth" 0. azimuth

  let multipoints () =
    let p1 = Coord.create ~x:1.0 ~y:3.0 in
    let p2 = Coord.create ~x:2.0 ~y:3.0 in
    let p3 = Coord.create ~x:3.0 ~y:3.0 in
    let coords = [| p1; p2; p3 |] in
    let mp = MultiPoint.create coords in
    let coords' = MultiPoint.coordinates mp in
    let mp' = MultiPoint.create coords' in
    Alcotest.(
      check (array arr) "same coordinates"
        (Array.map Coord.to_arr coords)
        (Array.map Coord.to_arr coords'));
    Alcotest.(
      check arr "same multipoints" (MultiPoint.to_arr mp) (MultiPoint.to_arr mp));
    Alcotest.(
      check arr "same multipoints" (MultiPoint.to_arr mp)
        (MultiPoint.to_arr mp'))

  let linestring () =
    let p1 = Coord.create ~x:1.0 ~y:3.0 in
    let p2 = Coord.create ~x:2.0 ~y:3.0 in
    let p3 = Coord.create ~x:3.0 ~y:3.0 in
    let mp = LineString.create [| p1; p2; p3 |] in
    let mp' = LineString.coordinates mp |> LineString.create in
    Alcotest.(
      check arr "same linestring" (LineString.to_arr mp) (LineString.to_arr mp));
    Alcotest.(
      check arr "same linestring" (LineString.to_arr mp) (LineString.to_arr mp'))

  let multilinestring () =
    let p1 = Coord.create ~x:1.0 ~y:3.0 in
    let p2 = Coord.create ~x:2.0 ~y:3.0 in
    let p3 = Coord.create ~x:3.0 ~y:3.0 in
    let l1 = LineString.create [| p1; p2; p3 |] in
    let l2 = LineString.create [| p1; p2; p3; p2; p1 |] in
    let ml = MultiLineString.create [| l1; l2 |] in
    let ml' =
      MultiLineString.create
      @@ [|
           LineString.of_arr
             (Floatarr.of_arrays
                [| [| 1.0; 3.0 |]; [| 2.0; 3.0 |]; [| 3.0; 3.0 |] |]);
           LineString.of_arr
             (Floatarr.of_arrays
                [|
                  [| 1.0; 3.0 |];
                  [| 2.0; 3.0 |];
                  [| 3.0; 3.0 |];
                  [| 2.0; 3.0 |];
                  [| 1.0; 3.0 |];
                |]);
         |]
    in
    Alcotest.(
      check (array arr) "same multilinestring"
        (MultiLineString.lines ml |> Array.map LineString.to_arr)
        (MultiLineString.lines ml' |> Array.map LineString.to_arr))

  let polygons () =
    let p1 = Coord.create ~x:1.0 ~y:3.0 in
    let p2 = Coord.create ~x:2.0 ~y:3.0 in
    let p3 = Coord.create ~x:3.0 ~y:3.0 in
    let i_p1 = Coord.create ~x:0.5 ~y:1.5 in
    let i_p2 = Coord.create ~x:1.0 ~y:1.5 in
    let i_p3 = Coord.create ~x:1.5 ~y:1.5 in
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
    Alcotest.(
      check (array arr) "same polygon"
        (Polygon.rings p |> Array.map LineString.to_arr)
        (Polygon.rings p' |> Array.map LineString.to_arr));
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
      check (array arr) "same polygon (with interior)"
        (Polygon.rings p_with_interior |> Array.map LineString.to_arr)
        (Polygon.rings ip' |> Array.map LineString.to_arr))

  let tests =
    [
      Alcotest.test_case "coord" `Quick test_azimuth;
      Alcotest.test_case "point" `Quick creation;
      Alcotest.test_case "multipoints" `Quick multipoints;
      Alcotest.test_case "linestring" `Quick linestring;
      Alcotest.test_case "multilinestring" `Quick multilinestring;
      Alcotest.test_case "polygon" `Quick polygons;
    ]
end

let () =
  Alcotest.run "geo"
    [ ("primitives", Test_prim.tests); ("algorithms", Test_algos.tests) ]
