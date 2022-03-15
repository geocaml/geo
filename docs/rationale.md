# Design Rationale

Ultimately the geospatial primitives are multi-dimensional arrays of floats. In OCaml a good candidate for this is the `Bigarray` module and in particular those provided by the excellent numerical library, [Owl](https://github.com/owlbarn/owl).

Another natural desire is to minimise the amount of data allocated by the OCaml runtime. This can happen when using non-constant variant constructions (like `Some x`), records, arrays etc. At the same time, the user experience shouldn't be compromised in favour of small performance gains (at least in the beginning when building the library). This short document shows some examples of how the geospatial primitives ended up in the format they are. A big thanks to [CraigFe](https://www.craigfe.io/) for his valuable input. If you see any mistakes or know how to make the interface better, please reach out.

```ocaml
# #require "owl-base";;
# module Darray = Owl_base_dense_ndarray_d;;
module Darray = Owl_base_dense_ndarray_d
```

In the following examples we'll keep things simple and only have `position`, `point` and `multipoint` to compare implementations. One first implementation notices that they are all geospatial primitives and so could be grouped as a sum-type.

```ocaml
type t = 
  | Position of Darray.arr
  | Point of Darray.arr
  | Multipoint of Darray.arr
```

At this point we now have our primitives and can build functions that must handle all of the possible primitives via pattern-matching. This is fine for some functions, for example:

```ocaml
# let to_arr = function
  | Position arr
  | Point arr
  | Multipoint arr -> arr;;
val to_arr : t -> Darray.arr = <fun>
```

But what if we only want to have functions work only on a subset of the primitives, for example a function that calculates the `centroid` of a primitive? With this setup, we're not using an OCaml type system features that would allow us to encode this.

```ocaml
type point = [ `point ]
type position = [ `position ]
type multipoint = [ `multipoint ]

type _ t = 
  | Position : Darray.arr -> [> position] t
  | Point : Darray.arr -> [> point] t
  | Multipoint : Darray.arr -> [> multipoint] t
```

And from here we can define functions using the subtyping that's available from polymorphic variants. Consider some function `f` that only works for positions and points, but not multipoints.

```ocaml
# let f = function
  | Position _ -> 1.
  | Point _ -> 2.;;
Lines 1-3, characters 9-18:
Warning 8 [partial-match]: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched:
Multipoint _
val f : [> `point | `position ] t -> float = <fun>
```

We need to help the compiler here by telling it the type.

```ocaml
# let f : [ position | point ] t -> float = function
  | Position _ -> 1.
  | Point _ -> 2.;;
val f : [ `point | `position ] t -> float = <fun>
```

And now if we try to use a multipoint here we'll get a compile time error, unfortunately it takes some getting used to the type errors to decipher the issue.

```ocaml
# f (Multipoint (Darray.zeros [| 2; 2|]));;
Line 1, characters 3-40:
Error: This expression has type ([> multipoint ] as 'a) t
       but an expression was expected of type [ `point | `position ] t
       Type 'a = [> `multipoint ] is not compatible with type
         [ `point | `position ]
       The second variant type does not allow tag(s) `multipoint
```

But with a point it works. 

```ocaml
# f (Point (Darray.zeros [| 2 |]));;
- : float = 2.
```

Great! With a little extra type information we can now define functions that work on subsets of the primitives. The error messages aren't great but maybe it is worth it.

One natural question after this is, can we remove the extra allocation? This is when we use the variant constructor to wrap the multidimensional array. Here, we start running up against the problem that OCaml uses a uniform runtime representation of values meaning we have no type information to help use distinguish values. One idea that feels could work is to only encode information in the "phantom type" of the primitives but not to distinguish them with variants.

```ocaml
# type _ t = Darray.arr;;
type _ t = Darray.arr
# let point : Darray.arr -> [> point ] t = Fun.id;;
val point : Darray.arr -> Darray.arr = <fun>
# let position : Darray.arr -> [> position ] t = Fun.id;;
val position : Darray.arr -> Darray.arr = <fun>
# let multipoint : Darray.arr -> [> multipoint ] t = Fun.id;;
val multipoint : Darray.arr -> Darray.arr = <fun>
```

But how do we distinguish between the values now in a function like `f`. We actually can't pattern-match anymore! We don't have any information to distinguish the values, but we have avoided the allocation.

```ocaml
# let f : [ position | point ] t -> float = fun arr -> 1.;;
val f : Darray.arr -> float = <fun>
```

We could have the user provide the information for us, but that is error prone! The user must now track the types of the multidimensional arrays which feels wrong. It certainly doesn't provide any guarantees about the shape of the array and as the application of `f` shows before, we've headed back to dynamic typing essentially.

```ocaml
# let f : [ position | point ] -> [ position | point ] t -> float = fun v arr -> match v with
  | `point -> 1.
  | `position -> 2.;;
val f : [ `point | `position ] -> Darray.arr -> float = <fun>
# f `point (position (Darray.zeros [| 2 |]));;
- : float = 1.
```

Is there a way to enforce the types to match up between the multi-dimensional array and the user-provided tag? Well, where there's a will there's a way. And that way is thanks to [CraigFe](https://github.com/CraigFe/).

```ocaml
module Tarr : sig
  type 'kind t
  val point : Darray.arr -> [ `point ] t 
  val position : Darray.arr -> [ `position ] t 
  val multipoint : Darray.arr -> [ `multipoint ] t 
end = struct 
  type _ t = Darray.arr
  let point : Darray.arr -> [ `point ] t = Fun.id
  let position : Darray.arr -> [ `position ] t = Fun.id
  let multipoint : Darray.arr -> [ `multipoint ] t = Fun.id
end

type (_, _) arr_kind =
  | Point : ([> `point ], [ `point ]) arr_kind
  | Position : ([> `position ], [ `position ]) arr_kind
  | Multipoint : ([> `multipoint ], [ `multipoint ]) arr_kind
```

The type `('sub, 'typ) arr_kind` is encoding both subtyping information along with the actual type itself which we can then use to unify with the information in the typed array `'a Tarr.t`.

```ocaml
# let f (type a) (kind : ([ `point | `position ], a) arr_kind) (_ : a Tarr.t) =
  match kind with Point -> 1. | Position -> 2.;;
val f : ([ `point | `position ], 'a) arr_kind -> 'a Tarr.t -> float = <fun>
# f Point (Tarr.point (Darray.zeros [| 2 |]));;
- : float = 1.
# f Point (Tarr.position (Darray.zeros [| 2 |]));;
Line 1, characters 9-47:
Error: This expression has type [ `position ] Tarr.t
       but an expression was expected of type [ `point ] Tarr.t
       These two variant types have no intersection
```
