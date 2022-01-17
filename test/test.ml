module Floatarr = Owl_base_dense_ndarray_d

let arr = Alcotest.testable Owl_pretty.pp_dsnda Floatarr.equal

module Test_prim = struct
  let creation () =
    let point = Geo.Point.create ~lng:3.0 ~lat:3.0 () in
    let point_arr = Geo.Point.to_arr point in
    let expect = Floatarr.create [| 2 |] 3.0 in
    Alcotest.(check arr "same ndarray" point_arr expect)

  let tests = [ Alcotest.test_case "point" `Quick creation ]
end

let () = Alcotest.run "geo" [ ("primitives", Test_prim.tests) ]
