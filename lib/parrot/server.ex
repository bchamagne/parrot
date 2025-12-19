defmodule Parrot.Server do
  defstruct [:name]

  # -- API --
  @spec start() :: pid()
  def start() do
    spawn(__MODULE__, :init, [])
  end

  @spec start_named(atom()) :: pid()
  def start_named(name) do
    pid = spawn(__MODULE__, :init, [name])
    Process.register(pid, name)
    pid
  end

  @spec stop(pid()) :: :ok | {:error, :timeout}
  def stop(pid) do
    ref = make_ref()
    from = self()
    send(pid, {:stop, {from, ref}})

    receive do
      {:reply, ^ref, :ok} ->
        :ok
    after
      1000 ->
        {:error, :timeout}
    end
  end

  @spec repeat(pid(), String.t()) :: {:ok, String.t()} | {:error, :timeout}
  def repeat(pid, text) do
    ref = make_ref()
    from = self()
    send(pid, {:repeat, {from, ref}, text})

    receive do
      {:reply, ^ref, reply} ->
        {:ok, reply}
    after
      1000 ->
        {:error, :timeout}
    end
  end

  # -- CALLBACKS --

  def init() do
    loop(%__MODULE__{name: "Le parrot inconnu"})
  end

  def init(name) do
    loop(%__MODULE__{name: name})
  end

  defp loop(state) do
    receive do
      {:repeat, {from, ref}, text} ->
        send(from, {:reply, ref, "#{state.name} says: #{text}"})
        loop(state)

      {:stop, {from, ref}} ->
        send(from, {:reply, ref, :ok})
    end
  end
end
