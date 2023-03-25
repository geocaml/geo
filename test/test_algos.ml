open Geo
module Floatarr = Owl_base_dense_ndarray_d

let arr = Alcotest.testable Owl_pretty.pp_dsnda Floatarr.equal
let rect = Alcotest.testable Rect.pp Rect.equal
let coord = Alcotest.testable Coord.pp Coord.equal

let line_coords =
  [|
    (-7.173885025695768, 54.592051806881045);
    (-7.003171072546536, 54.66486817448799);
    (-6.643773276441266, 54.628476285099964);
    (-6.5539238274153035, 54.86702708313797);
    (-6.194526031309977, 54.41989702349767);
    (-6.068736802673726, 54.72198962136258);
  |]

let bounding_box () =
  let linestring = Array.map (fun (x, y) -> Coord.create ~x ~y) line_coords in
  let linestring = LineString.create linestring in
  let bounding_box = LineString.bounding_box linestring in
  let expect =
    Rect.create
      (Coord.create ~x:(-7.173885025695768) ~y:54.41989702349767)
      (Coord.create ~x:(-6.068736802673726) ~y:54.86702708313797)
  in
  Alcotest.(check rect) "same bounding box" expect bounding_box

let line_string_intersection () =
  let seg1 = (Coord.create ~x:1.0 ~y:1.0, Coord.create ~x:3.0 ~y:3.0) in
  let seg2 = (Coord.create ~x:1.0 ~y:3.0, Coord.create ~x:3.0 ~y:1.0) in
  let l1 = LineString.create [| fst seg1; snd seg1 |] in
  let l2 = LineString.create [| fst seg2; snd seg2 |] in
  let intersections = LineString.intersects l1 l2 in
  Alcotest.(check (list (pair (pair coord coord) (pair coord coord))))
    "same intersections"
    [ (seg1, seg2) ]
    intersections

let polygon_intersection () =
  let seg1 = (Coord.create ~x:1.0 ~y:1.0, Coord.create ~x:1.0 ~y:3.0) in
  let seg2 = (Coord.create ~x:1.0 ~y:3.0, Coord.create ~x:3.0 ~y:3.0) in
  let seg3 = (Coord.create ~x:3.0 ~y:3.0, Coord.create ~x:3.0 ~y:1.0) in
  let seg4 = (Coord.create ~x:3.0 ~y:1.0, Coord.create ~x:1.0 ~y:1.0) in
  let l1 =
    LineString.create
      [|
        fst seg1;
        snd seg1;
        fst seg2;
        snd seg2;
        fst seg3;
        snd seg3;
        fst seg4;
        snd seg4;
      |]
  in
  let poly1 = Polygon.create [| l1 |] in
  let seg5 = (Coord.create ~x:2.0 ~y:2.0, Coord.create ~x:2.0 ~y:4.0) in
  let seg6 = (Coord.create ~x:2.0 ~y:4.0, Coord.create ~x:4.0 ~y:4.0) in
  let seg7 = (Coord.create ~x:4.0 ~y:4.0, Coord.create ~x:4.0 ~y:2.0) in
  let seg8 = (Coord.create ~x:4.0 ~y:2.0, Coord.create ~x:2.0 ~y:2.0) in
  let l2 =
    LineString.create
      [|
        fst seg5;
        snd seg5;
        fst seg6;
        snd seg6;
        fst seg7;
        snd seg7;
        fst seg8;
        snd seg8;
      |]
  in
  let poly2 = Polygon.create [| l2 |] in
  let intersections = Polygon.intersects poly1 poly2 in
  Alcotest.(check (list (pair (pair coord coord) (pair coord coord))))
    "same intersections"
    [ (seg2, seg5); (seg3, seg8) ]
    intersections

let chaikins_open () =
  let p1 = Coord.create ~x:3.0 ~y:0.0 in
  let p2 = Coord.create ~x:6.0 ~y:3.0 in
  let p3 = Coord.create ~x:3.0 ~y:6.0 in
  let p4 = Coord.create ~x:0.0 ~y:3.0 in
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
  let p1 = Coord.create ~x:3.0 ~y:0.0 in
  let p2 = Coord.create ~x:6.0 ~y:3.0 in
  let p3 = Coord.create ~x:3.0 ~y:6.0 in
  let p4 = Coord.create ~x:0.0 ~y:3.0 in
  let p5 = Coord.create ~x:3.0 ~y:0.0 in
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
    Alcotest.test_case "linestring_bounding_box" `Quick bounding_box;
    Alcotest.test_case "linestring_intersections" `Quick
      line_string_intersection;
    Alcotest.test_case "polygon_intersections" `Quick polygon_intersection;
  ]
