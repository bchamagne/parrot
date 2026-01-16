defmodule ParrotTest do
  use ExUnit.Case, async: true

  @eat_ms 100

  test "Starting and stopping a parrot" do
    {:ok, pid} = Parrot.start("Pickle")
    assert is_pid(pid)
    assert Process.alive?(pid)
    assert :ok = Parrot.stop(pid)
    refute Process.alive?(pid)
  end

  test "Unfed parrot will not do anything" do
    {:ok, pid} = Parrot.start("Peanut")
    assert "Peanut says: Feed me first, human!" = Parrot.repeat(pid, "Hello, pretty bird!")
  end

  test "Feeding unacceptable food will fail" do
    {:ok, pid} = Parrot.start("Pepper")
    assert "Pepper says: Not eating that!" = Parrot.eat(pid, :meat)
    assert "Pepper says: Not eating that!" = Parrot.eat(pid, :chocolate)
    assert "Pepper says: Feed me first, human!" = Parrot.repeat(pid, "Gimme a kiss!")
  end

  test "Each food grand one action" do
    {:ok, pid} = Parrot.start("Picasso")
    assert "Picasso says: Gochisousama deshita" = Parrot.eat(pid, :seed, @eat_ms)
    assert "Picasso says: Whatcha doin'?" = Parrot.repeat(pid, "Whatcha doin'?")
    assert "Picasso says: Feed me first, human!" = Parrot.repeat(pid, "Step up!")

    assert "Picasso says: Gochisousama deshita" = Parrot.eat(pid, :seed, @eat_ms)
    assert "Picasso says: Gochisousama deshita" = Parrot.eat(pid, :seed, @eat_ms)
    assert "Picasso says: Good morning!" = Parrot.repeat(pid, "Good morning!")
    assert "Picasso says: Want a treat?" = Parrot.repeat(pid, "Want a treat?")
    assert "Picasso says: Feed me first, human!" = Parrot.repeat(pid, "Pretty bird, pretty bird!")
  end

  test "Eating is a blocking operation" do
    {:ok, pid} = Parrot.start("Paco")
    test_pid = self()

    {time_microsec, _} =
      :timer.tc(fn ->
        spawn(fn ->
          _ = Parrot.eat(pid, :seed, @eat_ms)
          send(test_pid, :done)
        end)

        spawn(fn ->
          _ = Parrot.eat(pid, :nut, @eat_ms)
          send(test_pid, :done)
        end)

        spawn(fn ->
          _ = Parrot.eat(pid, :fruit, @eat_ms)
          send(test_pid, :done)
        end)

        assert_receive(:done, 1_000)
        assert_receive(:done, 1_000)
        assert_receive(:done, 1_000)
      end)

    assert time_microsec > @eat_ms * 1000 * 3
  end
end
