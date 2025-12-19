# Parrot


## Download deps 

```
mix deps.get
mix test
```

## Run in development 

```
iex -S mix
```


## Manual tests

```
pid = Parrot.start("Poncho")
Parrot.eat(pid, :nut)
Parrot.repeat(pid, "Night night!")
Parrot.repeat(pid, "Come here!")
Parrot.eat(pid, :fruit)
Parrot.think_about_life(pid)
```
