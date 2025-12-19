defmodule ParrotTest do
  use ExUnit.Case

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
end
