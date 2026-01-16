defmodule Parrot do
  @moduledoc """
  Documentation for `Parrot`.
  """

  defdelegate start(name), to: Parrot.Server
  defdelegate stop(pid), to: Parrot.Server
  defdelegate repeat(pid, text), to: Parrot.Server
  defdelegate eat(pid, food), to: Parrot.Server
  defdelegate eat(pid, food, millisec), to: Parrot.Server
end
