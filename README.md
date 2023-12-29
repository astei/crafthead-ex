# Crafthead, the Elixir version

To start the server:

  * Run `mix setup` to install and setup dependencies
  * Start the Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

It should go without saying that you will need a working Rust toolchain before you try to run this. (But if you create
a release, you shouldn't need that when running in production.)

Usage is identical to canonical [Crafthead](https://crafthead.net). All this really is taking the existing Rust bits
and putting it in a new guise, and then building a Phoenix server around it. (Phoenix can _sort of_ be used as a
microframework of sorts, if you disable most of the extra functionality it comes with.)

I make no guarantee of the quality of this for production use. I made this to learn Elixir and Phoenix with a project
I was pretty familiar with already. That said, the underlying Rust library has had 4 years of skins thrown at it, what
could go wrong?

Still need to write unit tests for the routes. That'll happen later.

There is no usage of Ecto going on here. You can put in any cache Nebulex supports, which can also be a SQL database if you
add `ecto`, `ecto_sql`, and your preferred pick of SQL server (although the favorite is probably going to be PostgreSQL). By
default, it will cache entries in a single in-memory ETS table, which is suitable for low-traffic workloads.