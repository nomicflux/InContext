use Mix.Config

config :ex_venture, Data.Repo,
  database: "ex_venture_dev",
  hostname: "localhost",
  username: "demouser",
  password: "password",
  pool_size: 10
