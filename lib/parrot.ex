defmodule Parrot do
  @moduledoc """
  Documentation for `Parrot`.
  """

  defdelegate start(), to: Parrot.Server

  defdelegate start_named(name), to: Parrot.Server

  defdelegate stop(pid), to: Parrot.Server

  defdelegate repeat(pid, text), to: Parrot.Server

  @doc "Synchronous"
  defdelegate eat(pid, food), to: Parrot.Server

  @doc "Synchronous"
  defdelegate eat(pid, food, millisec), to: Parrot.Server

  @doc "Asynchronous"
  defdelegate think_about_life(pid), to: Parrot.Server

  @doc "Asynchronous"
  defdelegate think_about_life(pid, millisec), to: Parrot.Server
end
