## Broken Record: A cheap and busted ORM

This is meant to be a demo program for Practicing Ruby. It is **not** suitable
for any real purpose. However, it may be a fun starting point for palying around
with design strategies for implementing object-relational mappers.

The most interesting thing about this codebase is that it attempts to implement
a design that is not heavily dependent on class inheritance and module mixins.
In fact, the only mixin used is BrokenRecord::Composable, which facilitates a
composition-based, object-oriented alternative to mixins. It is probably a bad
idea for a number of reasons, but is worth investigating.

To run the examples for this program, do the following:

1) Run `bundle` or manually install the `sqlite3` gem

2) Run any example in the examples/ folder

Broken Record itself does not have a hard dependency on the sqlite3 gem, but
does use SQLITE3 syntax exclusively. Its examples and tests use an in-memory
database, so you don't need to configure anything to try them out as long as you
have the dependencies installed. The examples will obviously make a lot more
sense if you've read Practicing Ruby issues 4.8 and 4.10, but if you just
stumbled across this repository by chance and have questions, feel free to email
gregory@practicingruby.com with questions.

Enjoy!!!
