# Parrot


## Download deps 

```
mix deps.get
```

## Run in development 

```
iex -S mix
```


## Manual tests

```
pid = Parrot.start()
Parrot.repeat(pid, "G'day!")
```

```
Parrot.start_named(:alfred)
Parrot.eat(:alfred, :nut)
Parrot.think_about_life(:alfred)
```