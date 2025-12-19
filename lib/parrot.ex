defmodule Parrot do
  @moduledoc """
  Documentation for `Parrot`.
  """

  @spec start() :: pid()
  defdelegate start(), to: Parrot.Server

  @spec start_named(atom()) :: pid()
  defdelegate start_named(name), to: Parrot.Server

  @spec stop(pid()) :: :ok | {:error, :timeout}
  defdelegate stop(pid), to: Parrot.Server

  @spec repeat(pid(), String.t()) :: {:ok, String.t()} | {:error, :timeout}
  defdelegate repeat(pid, text), to: Parrot.Server
end
