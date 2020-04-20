# Environment

An environment is where you can _deploy_ the project. A project must have at
least two environments, one for developing and testing, and another for
production. A project may have additional environments, such as one for
staging.

An environment must have:

- inventory for `ansible`
- a ruby script to launch, provision, and clean the environment
  (`inventories/$ENVIRONMENT/test_environment.rb`).
- corresponding group variable files under `playbooks/group_var`

Files for environments are under `inventories`.

The `Rakefile` with helps from helper ruby libraries launches the environment,
performs the `ansible` play, and runs tests.

An environment must be implemented so that users can deploy and test the
environment by running same commands.

It is assumed that machines in the environment belong to:

* `$ENVIRONMENT` `ansible` group
* `$ENVIRONMENT-credentials` `ansible` group
* `all` `ansible` group

`$ENVIRONMENT-credentials.yml` for `$ENVIRONMENT` `ansible` group must be
encrypted by `ansible-vault` unless it is `virtualbox` environment. Secret
information must NOT be used in `virtualbox` environment. Replace them with
fake ones.

Group variable files must be identical, in its format, to group variable files
for other environments so that users can easily see the differences by
`diff(1)`, or `vim --diff`. For example, if you have `virtualbox.yml` and
`prod.yml`, they should be identical except values. If `virtualbox.yml` is:

```yaml
---
foo: 1
bar: x
```

Then, `prod.yml` should be:

```yaml
---
foo: 2
bar: y
```

A bad example looks like this; when `virtualbox.yml` is

```yaml
---
foo: 1
bar: x
```

But `prod.yml` has a different order:

```yaml
---
bar: y
foo: 2
```

Environment-specific variables should not be used in shared group variable
files. If `foo.yml` needs environment-specific values, use a variable with
`project_` prefix in its name. For example, if you need a password, create
`foo.yml`:

```yaml
---
password: "{{ project_password }}"
```

And `virtualbox-credentials.yml` and encrypted `prod-credentials.yml` should
define `project_password`.

```yaml
---
# virtualbox-credentials.yml
project_password: fake password
```

```yaml
---
# prod-credentials.yml
project_password: real password
```

## Default environments

### `virtualbox` environment

This is a testing environment. `virtualbox` was chosen as a testing platform
because it is portable, i.e. it supports Windows, macOS, Linux, and some BSDs.

### `prod` environment

This is the production environment.

## Creating an environment

TBW
