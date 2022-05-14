open Geo
module Floatarr = Owl_base_dense_ndarray_d

let arr = Alcotest.testable Owl_pretty.pp_dsnda Floatarr.equal

let chaikins_open () =
  let p1 = Coordinate.create ~x:3.0 ~y:0.0 in
  let p2 = Coordinate.create ~x:6.0 ~y:3.0 in
  let p3 = Coordinate.create ~x:3.0 ~y:6.0 in
  let p4 = Coordinate.create ~x:0.0 ~y:3.0 in
  let l1 = LineString.create [| p1; p2; p3; p4 |] in
  let l2 = LineString.chaikin_smoothing 1 l1 in
  let l2' =
    LineString.of_arr
      (Floatarr.of_arrays
         [|
           [| 3.0; 0.0 |];
           [| 3.75; 0.75 |];
           [| 5.25; 2.25 |];
           [| 5.25; 3.75 |];
           [| 3.75; 5.25 |];
           [| 2.25; 5.25 |];
           [| 0.75; 3.75 |];
           [| 0.0; 3.0 |];
         |])
  in
  Alcotest.(
    check arr "same linestring" (LineString.to_arr l2') (LineString.to_arr l2))

let chaikins_closed () =
  let p1 = Coordinate.create ~x:3.0 ~y:0.0 in
  let p2 = Coordinate.create ~x:6.0 ~y:3.0 in
  let p3 = Coordinate.create ~x:3.0 ~y:6.0 in
  let p4 = Coordinate.create ~x:0.0 ~y:3.0 in
  let p5 = Coordinate.create ~x:3.0 ~y:0.0 in
  let l1 = LineString.create [| p1; p2; p3; p4; p5 |] in
  let l2 = LineString.chaikin_smoothing 1 l1 in
  let l2' =
    LineString.of_arr
      (Floatarr.of_arrays
         [|
           [| 3.75; 0.75 |];
           [| 5.25; 2.25 |];
           [| 5.25; 3.75 |];
           [| 3.75; 5.25 |];
           [| 2.25; 5.25 |];
           [| 0.75; 3.75 |];
           [| 0.75; 2.25 |];
           [| 2.25; 0.75 |];
           [| 3.75; 0.75 |];
         |])
  in
  Alcotest.(
    check arr "same linestring" (LineString.to_arr l2') (LineString.to_arr l2))

let tests =
  [
    Alcotest.test_case "chaikin_open" `Quick chaikins_open;
    Alcotest.test_case "chaikin_closed" `Quick chaikins_closed;
  ]
