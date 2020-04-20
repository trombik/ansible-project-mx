# Environment

An environment is where you can _deploy_ the project. A project must have at
least two environments, one for developing and testing, and another for
production. A project may have additional environments, such as one for
staging.

An environment must have:

- inventory for `ansible`
- a ruby script to launch, provision, and clean the environment
  (`inventories/$ENVIRONMENT/test_environment.rb`).

Files for environments are under `inventories`.

The `Rakefile` with helps from helper ruby libraries launches the environment,
performs the `ansible` play, and runs tests.

An environment must be implemented so that users can deploy and test the
environment by running same commands.

## Default environments

### `virtualbox` environment

This is a testing environment. `virtualbox` was chosen as a testing platform
because it is portable, i.e. it supports Windows, macOS, Linux, and some BSDs.

### `prod` environment

This is the production environment.

## Creating an environment

TBW
