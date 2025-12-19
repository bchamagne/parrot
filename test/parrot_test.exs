defmodule ParrotTest do
  use ExUnit.Case

  @think_about_life_ms 100
  @eat_ms 100

  test "Unnamed parrot repeat after me" do
    text = "Hello world!"
    pid = Parrot.start()
    assert is_pid(pid)
    assert Process.alive?(pid)
    assert {:ok, reply} = Parrot.repeat(pid, text)
    assert reply =~ text

    text = :crypto.strong_rand_bytes(32)
    assert {:ok, reply} = Parrot.repeat(pid, text)
    assert reply =~ text
  end

  test "Named parrot repeat after me" do
    name = :alfred
    pid = Parrot.start_named(name)
    assert is_pid(pid)
    assert name |> Process.whereis() |> Process.alive?()

    text = "Hello world!"
    assert {:ok, reply} = Parrot.repeat(name, text)
    assert reply =~ text
    assert reply =~ Atom.to_string(name)
    text = :crypto.strong_rand_bytes(32)
    assert {:ok, reply} = Parrot.repeat(name, text)
    assert reply =~ text
    assert reply =~ Atom.to_string(name)
  end

  test "Stop should work" do
    pid = Parrot.start()
    assert is_pid(pid)
    Parrot.stop(pid)
    refute Process.alive?(pid)

    name = :jane
    pid = Parrot.start_named(name)
    assert is_pid(pid)
    assert Process.alive?(pid)

    Parrot.stop(pid)
    refute Process.alive?(pid)

    name = :mike
    _ = Parrot.start_named(name)
    assert name |> Process.whereis() |> Process.alive?()

    Parrot.stop(name)
    assert is_nil(name |> Process.whereis())
  end

  test "Thinking about life is a slow operation" do
    pid = Parrot.start()

    {time_microsec, result} =
      :timer.tc(fn ->
        Parrot.think_about_life(pid, @think_about_life_ms)
      end)

    assert {:ok, _} = result
    assert time_microsec > @think_about_life_ms * 1000
  end

  test "Thinking about life is a non-blocking operation" do
    pid = Parrot.start()
    test_pid = self()

    {time_microsec, _} =
      :timer.tc(fn ->
        spawn(fn ->
          {:ok, _} = Parrot.think_about_life(pid, @think_about_life_ms)
          send(test_pid, :done)
        end)

        spawn(fn ->
          {:ok, _} = Parrot.think_about_life(pid, @think_about_life_ms)
          send(test_pid, :done)
        end)

        spawn(fn ->
          {:ok, _} = Parrot.think_about_life(pid, @think_about_life_ms)
          send(test_pid, :done)
        end)

        assert_receive(:done, 1_000)
        assert_receive(:done, 1_000)
        assert_receive(:done, 1_000)
      end)

    assert time_microsec < @think_about_life_ms * 1000 * 3
  end

  test "Eating is a blocking operation" do
    pid = Parrot.start()
    test_pid = self()

    {time_microsec, _} =
      :timer.tc(fn ->
        spawn(fn ->
          {:ok, _} = Parrot.eat(pid, :seed, @eat_ms)
          send(test_pid, :done)
        end)

        spawn(fn ->
          {:ok, _} = Parrot.eat(pid, :nut, @eat_ms)
          send(test_pid, :done)
        end)

        spawn(fn ->
          {:ok, _} = Parrot.eat(pid, :fruit, @eat_ms)
          send(test_pid, :done)
        end)

        assert_receive(:done, 1_000)
        assert_receive(:done, 1_000)
        assert_receive(:done, 1_000)
      end)

    assert time_microsec > @eat_ms * 1000 * 3
  end
end
