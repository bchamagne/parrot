defmodule Parrot.Server do
  defstruct [:name]

  @food_acceptable [:seed, :nut, :fruit, :vegetable]

  @quotes [
    {"Man is condemned to be free; because once thrown into the world, he is responsible for everything he does.",
     "Jean-Paul Sartre"},
    {"The literal meaning of life is whatever you're doing that prevents you from killing yourself.",
     "Albert Camus"},
    {"We are our choices.", "Jean-Paul Sartre"},
    {"Life has no meaning the moment you lose the illusion of being eternal.",
     "Jean-Paul Sartre"},
    {"The only way to deal with an unfree world is to become so absolutely free that your very existence is an act of rebellion.",
     "Albert Camus"}
  ]

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

  @spec eat(pid(), atom()) :: {:ok, String.t()} | {:error, :timeout}
  @spec eat(pid(), atom(), integer()) :: {:ok, String.t()} | {:error, :timeout}
  def eat(pid, food, millisec \\ 1_000) do
    ref = make_ref()
    from = self()
    send(pid, {:eat, {from, ref}, food, millisec})

    receive do
      {:reply, ^ref, reply} ->
        {:ok, reply}
    after
      millisec + 1_000 ->
        {:error, :timeout}
    end
  end

  @spec think_about_life(pid()) :: {:ok, String.t()} | {:error, :timeout}
  @spec think_about_life(pid(), integer()) :: {:ok, String.t()} | {:error, :timeout}
  def think_about_life(pid, millisec \\ 5_000) do
    ref = make_ref()
    from = self()
    send(pid, {:think_about_life, {from, ref}, millisec})

    receive do
      {:reply, ^ref, reply} ->
        {:ok, reply}
    after
      millisec + 1_000 ->
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

      {:eat, {from, ref}, food, millisec} ->
        if food in @food_acceptable do
          Process.sleep(millisec)
          send(from, {:reply, ref, "#{state.name} says: Gochisousama deshita"})
          loop(state)
        else
          send(from, {:reply, ref, "#{state.name} says: No way"})
          loop(state)
        end

      {:think_about_life, {from, ref}, millisec} ->
        spawn_link(fn ->
          Process.sleep(millisec)
          {quote_, author} = Enum.random(@quotes)
          send(from, {:reply, ref, "#{state.name} says: #{quote_} - #{author}"})
        end)

        loop(state)

      {:stop, {from, ref}} ->
        send(from, {:reply, ref, :ok})
    end
  end
end
