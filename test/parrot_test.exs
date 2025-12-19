defmodule ParrotTest do
  use ExUnit.Case, async: true

  @think_about_life_ms 100
  @eat_ms 100

  test "Starting and stopping a parrot" do
    pid = Parrot.start("Pickle")
    assert is_pid(pid)
    assert Process.alive?(pid)
    assert :ok = Parrot.stop(pid)
    refute Process.alive?(pid)
  end

  test "Unfed parrot will not do anything" do
    pid = Parrot.start("Peanut")
    assert {:error, :unfed_parrot} = Parrot.repeat(pid, "Hello, pretty bird!")
    assert {:error, :unfed_parrot} = Parrot.think_about_life(pid)
  end

  test "Feeding unacceptable food will fail" do
    pid = Parrot.start("Pepper")
    assert {:error, :unacceptable_food} = Parrot.eat(pid, :meat)
    assert {:error, :unacceptable_food} = Parrot.eat(pid, :chocolate)
    assert {:error, :unfed_parrot} = Parrot.repeat(pid, "Gimme a kiss!")
    assert {:error, :unfed_parrot} = Parrot.think_about_life(pid)
  end

  test "Each food grand one action" do
    pid = Parrot.start("Picasso")
    assert {:ok, "Picasso says: Gochisousama deshita"} = Parrot.eat(pid, :seed, @eat_ms)
    assert {:ok, "Picasso says: Whatcha doin'?"} = Parrot.repeat(pid, "Whatcha doin'?")
    assert {:error, :unfed_parrot} = Parrot.repeat(pid, "Step up!")

    assert {:ok, "Picasso says: Gochisousama deshita"} = Parrot.eat(pid, :seed, @eat_ms)
    assert {:ok, "Picasso says: " <> _} = Parrot.think_about_life(pid, @think_about_life_ms)
    assert {:error, :unfed_parrot} = Parrot.think_about_life(pid, @think_about_life_ms)

    assert {:ok, "Picasso says: Gochisousama deshita"} = Parrot.eat(pid, :seed, @eat_ms)
    assert {:ok, "Picasso says: Gochisousama deshita"} = Parrot.eat(pid, :seed, @eat_ms)
    assert {:ok, "Picasso says: Good morning!"} = Parrot.repeat(pid, "Good morning!")
    assert {:ok, "Picasso says: Want a treat?"} = Parrot.repeat(pid, "Want a treat?")
    assert {:error, :unfed_parrot} = Parrot.repeat(pid, "Pretty bird, pretty bird!")
  end

  test "Thinking about life is a non-blocking operation" do
    pid = Parrot.start("Polly")
    {:ok, _} = Parrot.eat(pid, :seed, @eat_ms)
    {:ok, _} = Parrot.eat(pid, :seed, @eat_ms)
    {:ok, _} = Parrot.eat(pid, :seed, @eat_ms)
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
    pid = Parrot.start("Paco")
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
