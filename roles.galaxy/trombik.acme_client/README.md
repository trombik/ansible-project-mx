# `trombik.acme_client`

[![Build Status](https://travis-ci.com/trombik/ansible-role-acme_client.svg?branch=master)](https://travis-ci.com/trombik/ansible-role-acme_client)

Manage `acme-client(1)`, `acme-client.conf(5)`, and cron jobs.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `acme_client_challengedirs` | `challengedir` in `acme-client.conf(5)` | `{{ __acme_client_challengedirs }}` |
| `acme_client_conf_dir` | Path to base directory of `acme-client.conf(5)` | `{{ __acme_client_conf_dir }}` |
| `acme_client_conf_file` | Path to `acme-client.conf(5)` | `{{ acme_client_conf_dir }}/acme-client.conf` |
| `acme_client_account_key_dir` | Directory for private keys for `acme-client(1)` | `{{ __acme_client_account_key_dir }}` |
| `acme_client_config` | Content of `acme-client.conf(5)` | `""` |
| `acme_client_flags` | Flags for `acme-client(1)` | `""` |
| `acme_client_domains` | List of domains to manage | `[]` |
| `acme_client_hanlder` | Enable or disable the handler to update certs | `disabled` |
| `acme_client_flush_handlers` | Run `flush_handlers` at the end of the role | `false` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__acme_client_challengedirs` | `["/var/www/acme"]` |
| `__acme_client_conf_dir` | `/etc` |
| `__acme_client_account_key_dir` | `/etc/acme` |

# Dependencies

None

# Example Playbook

```yaml
---
- hosts: localhost
  roles:
    - ansible-role-acme_client
  vars:
    acme_client_flags: "-f {{ acme_client_conf_file }} -vv"
    acme_client_domains:
      - example.org
      - example.net
    acme_client_config: |
      authority letsencrypt {
        api url "https://acme-v02.api.letsencrypt.org/directory"
        account key "/etc/acme/letsencrypt-privkey.pem"
      }

      authority letsencrypt-staging {
          api url "https://acme-staging-v02.api.letsencrypt.org/directory"
          account key "/etc/acme/letsencrypt-staging-privkey.pem"
      }

      domain example.org {
          alternative names { www.example.com }
          domain key "/etc/ssl/private/example.org.key"
          domain full chain certificate "/etc/ssl/example.org.fullchain.pem"
          sign with letsencrypt
      }

      domain example.net {
          alternative names { www.example.com }
          domain key "/etc/ssl/private/example.net.key"
          domain full chain certificate "/etc/ssl/example.net.fullchain.pem"
          sign with letsencrypt
      }

    acme_client_cron_jobs:
      - name: example.org
        cron:
          name: Check cert for example.org
          hour: 8

          # XXX use `~` here on OpenBSD 6.7
          minute: 45
          job: "acme-client {{ acme_client_flags }} example.org"

      - name: example.net
        cron:
          name: Check cert for example.net
          hour: 9
          minute: 45
          job: "acme-client {{ acme_client_flags }} example.net"
```

# License

```
Copyright (c) 2020 Tomoyuki Sakurai <y@trombik.org>

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
