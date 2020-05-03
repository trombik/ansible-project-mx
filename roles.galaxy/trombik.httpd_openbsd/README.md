# `trombik.httpd_openbsd`

[![Build Status](https://travis-ci.org/trombik/ansible-role-httpd-openbsd.svg?branch=master)](https://travis-ci.org/trombik/ansible-role-httpd-openbsd)

Manages `httpd(8)` from OpenBSD

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `httpd_openbsd_user` | user of `httpd(8)` | `{{ __httpd_openbsd_user }}` |
| `httpd_openbsd_group` | group of `httpd(8)` | `{{ __httpd_openbsd_group }}` |
| `httpd_openbsd_log_directories` | list of directories to create (see below) | `[]` |
| `httpd_openbsd_service` | service name of `httpd(8)` | `{{ __httpd_openbsd_service }}` |
| `httpd_openbsd_conf_dir` | `dirname` of `httpd.conf` | `{{ __httpd_openbsd_conf_dir }}` |
| `httpd_openbsd_conf_file` | path to `httpd.conf` | `{{ httpd_openbsd_conf_dir }}/httpd.conf` |
| `httpd_openbsd_flags` | flags to pass in `rc.conf.local` | `-f {{ httpd_openbsd_conf_file }}` |
| `httpd_openbsd_chroot` | not yet implemented | `""` |
| `httpd_openbsd_config` | content of `httpd.conf` | `""` |

## `httpd_openbsd_log_directories`

This variable is a thin wrapper of `ansible`'s `file` module, and a list of
dict explained below.

| Attribute name | Value | Mandatory? |
|----------------|-------|------------|
| `path` | `path` of `file` module | yes |
| `mode` | `mode` of `file` module | no |
| `owner` | `owner` of `file` module | no |
| `group` | `group` of `file` module | no |
| `state` | either `present` or `absent`. when `present`, the directory is created. when `absent`, the directory is removed | yes |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__httpd_openbsd_user` | `www` |
| `__httpd_openbsd_group` | `www` |
| `__httpd_openbsd_service` | `httpd` |
| `__httpd_openbsd_conf_dir` | `/etc` |

# Dependencies

None

# Example Playbook

```yaml
---
- hosts: localhost
  roles:
    - ansible-role-httpd-openbsd
  vars:
    httpd_openbsd_log_directories:
      - path: /var/www/logs
        owner: root
        group: daemon
        mode: 0755
        state: present
      - path: /var/www/logs/secure
        owner: root
        group: daemon
        mode: g+w
        state: present

    httpd_openbsd_config: |
      ext_addr="*"
      prefork 3
      # A minimal default server
      server "default" {
        listen on $ext_addr port 80
      }

      # An HTTPS server using SSL/TLS
      #server "secure.example.com" {
      #  listen on $ext_addr tls port 443
      #  log { access "secure-access.log", error "secure-error.log" }
      #}
      # Include MIME types instead of the built-in ones
      types {
        include "/usr/share/misc/mime.types"
      }
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
