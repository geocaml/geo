(lang dune 3.2)
(name geo)
(generate_opam_files true)
(source (github geocaml/geo))
(authors "patrick@sirref.org")
(maintainers "patrick@sirref.org")
(using mdx 0.3)
(package
 (name geo)
 (synopsis "Geospatial Primitives and Algorithms")
 (description "")
 (depends
  owl-base
  (mdx :with-test)
  (alcotest :with-test)))