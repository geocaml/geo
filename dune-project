(lang dune 2.9)
(name geo)
(generate_opam_files true)
(source (github geocaml/geo))
(authors "patrick@sirref.org")
(maintainers "patrick@sirref.org")
(using mdx 0.1)
(package
 (name geo)
 (synopsis "Geospatial Primitives and Algorithms")
 (description "")
 (depends
  owl-base
  (mdx :with-test)
  (alcotest :with-test)))