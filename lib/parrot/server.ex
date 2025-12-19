defmodule Parrot.Server do
  defstruct [:name, :energy]

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
  @spec start(String.t()) :: pid()
  def start(name) do
    spawn(__MODULE__, :init, [name])
  end

  @spec stop(pid()) :: :ok | {:error, :timeout}
  def stop(pid) when is_pid(pid) do
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

  @spec repeat(pid(), String.t()) :: {:ok, String.t()} | {:error, :timeout | :unfed_parrot}
  def repeat(pid, text) when is_pid(pid) and is_binary(text) do
    ref = make_ref()
    from = self()
    send(pid, {:repeat, {from, ref}, text})

    receive do
      {:reply, ^ref, :unfed_parrot} ->
        {:error, :unfed_parrot}

      {:reply, ^ref, reply} ->
        {:ok, reply}
    after
      1000 ->
        {:error, :timeout}
    end
  end

  @spec eat(pid(), atom()) :: {:ok, String.t()} | {:error, :timeout}
  @spec eat(pid(), atom(), integer()) :: {:ok, String.t()} | {:error, :timeout}
  def eat(pid, food, millisec \\ 2_000)
      when is_pid(pid) and is_atom(food) and is_integer(millisec) do
    ref = make_ref()
    from = self()
    send(pid, {:eat, {from, ref}, food, millisec})

    receive do
      {:reply, ^ref, :unacceptable_food} ->
        {:error, :unacceptable_food}

      {:reply, ^ref, reply} ->
        {:ok, reply}
    after
      millisec + 1_000 ->
        {:error, :timeout}
    end
  end

  @spec think_about_life(pid()) :: {:ok, String.t()} | {:error, :timeout}
  @spec think_about_life(pid(), integer()) :: {:ok, String.t()} | {:error, :timeout}
  def think_about_life(pid, millisec \\ 5_000)
      when is_pid(pid) and is_integer(millisec) do
    ref = make_ref()
    from = self()
    send(pid, {:think_about_life, {from, ref}, millisec})

    receive do
      {:reply, ^ref, :unfed_parrot} ->
        {:error, :unfed_parrot}

      {:reply, ^ref, reply} ->
        {:ok, reply}
    after
      millisec + 1_000 ->
        {:error, :timeout}
    end
  end

  # -- CALLBACKS --

  def init(name) do
    loop(%__MODULE__{name: name, energy: 0})
  end

  defp loop(state) do
    receive do
      {:eat, {from, ref}, food, millisec} when food in @food_acceptable ->
        new_state = do_increment_energy(state, food)
        reply = do_eat_food(food, millisec)
        send(from, {:reply, ref, "#{state.name} says: #{reply}"})
        loop(new_state)

      {:eat, {from, ref}, _food, _millisec} ->
        send(from, {:reply, ref, :unacceptable_food})
        loop(state)

      {:repeat, {from, ref}, text} when state.energy > 0 ->
        new_state = do_consume_energy(state)
        send(from, {:reply, ref, "#{state.name} says: #{do_repeat(text)}"})
        loop(new_state)

      {:repeat, {from, ref}, _text} ->
        send(from, {:reply, ref, :unfed_parrot})
        loop(state)

      {:think_about_life, {from, ref}, millisec} when state.energy > 0 ->
        new_state = do_consume_energy(state)

        spawn_link(fn ->
          send(from, {:reply, ref, "#{state.name} says: #{do_think_about_life(millisec)}"})
        end)

        loop(new_state)

      {:think_about_life, {from, ref}, _millisec} ->
        send(from, {:reply, ref, :unfed_parrot})
        loop(state)

      {:stop, {from, ref}} ->
        send(from, {:reply, ref, :ok})
    end
  end

  defp do_increment_energy(state, _food) do
    %__MODULE__{state | energy: state.energy + 1}
  end

  defp do_consume_energy(%__MODULE__{energy: energy} = state) when energy > 0 do
    %__MODULE__{state | energy: energy - 1}
  end

  defp do_repeat(text) do
    text
  end

  defp do_eat_food(_food, millisec) do
    Process.sleep(millisec)
    "Gochisousama deshita"
  end

  defp do_think_about_life(millisec) do
    Process.sleep(millisec)
    {quote_, author} = Enum.random(@quotes)
    "#{quote_} - #{author}"
  end
end
