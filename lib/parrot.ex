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

  @doc "Synchronous (blocking) operation"
  @spec eat(pid(), atom(), integer()) :: {:ok, String.t()} | {:error, :timeout}
  defdelegate eat(pid, food, millisec), to: Parrot.Server

  @doc "Asynchronous operation"
  @spec think_about_life(pid(), integer()) :: {:ok, String.t()} | {:error, :timeout}
  defdelegate think_about_life(pid, millisec), to: Parrot.Server
end
