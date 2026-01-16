defmodule Parrot.Server do
  defstruct [:name, :energy]

  @food_acceptable [:seed, :nut, :fruit, :vegetable]

  # -- API --
  def start(name) do
    :gen_statem.start(__MODULE__, [name], [])
  end

  def stop(pid) when is_pid(pid) do
    :gen_statem.stop(pid)
  end

  def repeat(pid, text)
      when is_pid(pid) and is_binary(text) do
    :gen_statem.call(pid, {:repeat, text})
  end

  def eat(pid, food, millisec \\ 2_000)
      when is_pid(pid) and is_atom(food) and is_integer(millisec) do
    :gen_statem.call(pid, {:eat, food, millisec})
  end

  # -- CALLBACKS --

  def init(name) do
    {:ok, :hungry, %__MODULE__{name: name, energy: 0}}
  end

  def callback_mode, do: :state_functions

  def hungry({:call, from}, {:repeat, _text}, data) do
    {:keep_state, data, [reply(from, data, "Feed me first, human!")]}
  end

  def hungry({:call, from}, {:eat, food, millisec}, data) do
    {data, text} = do_eat_food(data, food, millisec)

    if data.energy > 0 do
      {:next_state, :fed, data, [reply(from, data, text)]}
    else
      {:keep_state, data, [reply(from, data, text)]}
    end
  end

  def fed({:call, from}, {:repeat, text}, data) do
    case do_consume_energy(data) do
      data when data.energy == 0 ->
        {:next_state, :hungry, data, [reply(from, data, text)]}

      data ->
        {:keep_state, data, [reply(from, data, text)]}
    end
  end

  def fed({:call, from}, {:eat, food, millisec}, data) do
    {data, text} = do_eat_food(data, food, millisec)
    {:keep_state, data, [reply(from, data, text)]}
  end

  defp do_consume_energy(%__MODULE__{energy: energy} = data)
       when energy > 0 do
    %{data | energy: energy - 1}
  end

  defp do_eat_food(%__MODULE__{} = data, food, millisec)
       when food in @food_acceptable do
    Process.sleep(millisec)
    data = %{data | energy: data.energy + 1}
    {data, "Gochisousama deshita"}
  end

  defp do_eat_food(data, _food, _millisec), do: {data, "Not eating that!"}

  defp reply(from, %__MODULE__{} = data, text) do
    {:reply, from, "#{data.name} says: #{text}"}
  end
end
