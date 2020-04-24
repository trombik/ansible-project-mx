# Style

## General

Prefer portability. Portable code finds your bugs.

## Ruby

Follow what `rubocop` says.

Use `rspec` for tests.

Ruby libraries specific to projects should be kept under `ruby` directory.

## Python

We do not have a style policy yet.

## Shell

Use `/bin/sh`.

Respect POSIX.

Avoid bash-ism.

## YAML

Follow what `yamllint` says.

### Markdown

Follow what `markdownlint-cli` says.

When you need "Table of Content", use:

```console
> node node_modules/markdown-toc/cli.js --no-firsth1 --bullets='-' path/to/file
```

You may want to use `-i` flag with above command. See:

```console
> node node_modules/markdown-toc/cli.js --help
```

## Comments

An empty line must be followed by comments.

Prefer single, or multi, line comment, not inline comments.

## Line feed

Use `LF`, not `CR` `LF`.

## File encoding

Use UTF-8.

## Language

Use English throughout the project.

## Path

Do not use absolute path unless necessary.
