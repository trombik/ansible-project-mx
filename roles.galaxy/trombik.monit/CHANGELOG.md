# CHANGELOG

## Release 2.0.1

* 975811a bugfix: fix path to python on FreeBSD
* 4e10221 bugfix: notify monit when files change

## Release 2.0.0

### Backward incompatibilities

#### Introducing `monit_config`

Previously, the content of `monitrc` had been hard-coded, but not any more. The
new variable `monit_config` allows to create arbitrary configuration.

```
monit_conf_daemon: 10
monit_conf_start_delay: 180

monit_conf_httpd_enable: True
monit_conf_httpd_address: 127.0.0.1
monit_conf_httpd_port: 2812
monit_conf_httpd_allow:
  - 127.0.0.1

monit_conf_logfile_syslog_facility: log_daemon
```

The following variables has gone in this release.

* `monit_conf_daemon`
* `monit_conf_start_delay`
* `monit_conf_httpd_enable`
* `monit_conf_httpd_address`
* `monit_conf_httpd_port`
* `monit_conf_httpd_allow`

They must be removed and ported using `monit_config`.

#### `monit_rc` supports `state`

`monit_rc` is now dict of dict and supports `state`, which enables to remove
configuration fragments. When previous `monit_rc` looks like:

```yaml
monit_rc:
  sshd:
    check process sshd with pidfile /var/run/sshd.pid
      start program "/bin/systemctl start sshd"
      stop program  "/bin/systemctl stop sshd"
      every 2 cycles
      if failed port 22 protocol ssh then restart
```

which must be rewritten to:

```yaml
monit_rc:
  sshd:
    state: present
    content: |
      check process sshd with pidfile /var/run/sshd.pid
        start program "/bin/systemctl start sshd"
        stop program  "/bin/systemctl stop sshd"
        every 2 cycles
        if failed port 22 protocol ssh then restart
```


## Release 1.0.0

* Initail release
