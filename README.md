[![progress-banner](https://backend.codecrafters.io/progress/redis/2b314456-f040-4e80-a01a-33ac1bf1d441)](https://app.codecrafters.io/users/codecrafters-bot?r=2qF)

This is a Ruby solutions to the
["Build Your Own Redis" Challenge](https://codecrafters.io/challenges/redis).

It builds a toy redis implementation in Ruby.

I've added my own tests for fun.

# Installation

See the tools versions in .mise.toml file. Use [mise](https://github.com/jdx/mise) or your favorite ruby version manager.

# Running

You can run the program using `ruby app/main.rb` or `./spawn_redis_server.sh` which just wraps that command.

# Install dependencies

For local development you can install the dependencies with `bundle`.

```sh
# make sure you have bundle, other wise `gem install bundler`
bundle install
```

# Testing

You can install `redis` and use the `redis-cli` to interact with the program.

```sh
ruby app/main.rb & # put the process in the background and note the PID
redis-cli ping # send command to the program and see output
# you call then `kill <PID>` to terminate the program
```

You can also run the tests with rspec:

```sh
rspec
```
