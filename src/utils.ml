(* https://github.com/owlbarn/owl/blob/78b407c0a5f6938dc09c3dc98ee65ffcdcee64f5/src/owl/dense/owl_dense_ndarray_generic.ml#L8460-L8468 *)
let sub_ndarray parts x =
  let n = Array.fold_left ( + ) 0 parts in
  let s =
    Printf.sprintf "n = %i, (shape x).(0) = %i"
      (Owl_base_dense_ndarray_generic.shape x).(0)
      n
  in
  Owl_exception.(
    check
      (n = (Owl_base_dense_ndarray_generic.shape x).(0))
      (INVALID_ARGUMENT s));
  let m = Array.length parts in
  let ofs = ref (-parts.(0)) in
  Array.init m (fun i ->
      ofs := !ofs + parts.(i);
      Bigarray.Genarray.sub_left x !ofs parts.(i))
