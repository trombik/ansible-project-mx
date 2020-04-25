# MTA for `trombik.org`

## Table of Contents

<!-- toc -->

- [Purpose](#purpose)
- [Overview](#overview)
- [Requirements](#requirements)
- [Out-of-scope](#out-of-scope)
- [Implementations](#implementations)
  - [MTA](#mta)
  - [IMAP](#imap)
  - [Authoritative DNS server](#authoritative-dns-server)
- [Environments](#environments)
  - [`virtualbox`](#virtualbox)
  - [`staging`](#staging)
  - [`prod`](#prod)

<!-- tocstop -->

## Purpose

The purpose of the project is to provide email services to me. Additionally,
it will host other domains I own, such as domains used for my business.

## Overview

The project deploys an MTA on AWS. To save money, the MTA also hosts an IMAP
server, and an authoritative DNS server.

In general, you should not assign multiple roles to a host. However, until the
pandemic, and the panic reactions from it, is over, I would like to reduce
running costs. The authoritative DNS server should be removed from the MTA
after that.

The MTA accepts messages to the following domains:

- `trombik.org` and its sub-domains

The MTA accepts messages from users of the following domains:

- `trombik.org` and its sub-domains

These messages will be relayed to the destination MTA.

The IMAP server manages inboxes for the following domains:

- `trombik.org` and its sub-domains

## Requirements

- for mailbox access, IMAP must be used
- for mailbox access, POP3 MAY be implemented
- for mailbox access, Web UI MAY be implemented
- message transfer, including login credentials, MUST be protected by
  transport layer security (TLS) where possible
- the MTA must be able to relay messages to major email service providers
  without warning, i.e. successful SPF, and DKIM tests
- the major email service providers must include Gmail
- all email users MUST be a virtual user. Unix user should not be used as mail
  users
- all server applications MUST be monitored. When any of them is down, or
  stops working, the daemon MUST be restarted automatically
- Public keys for TLS MUST be valid in production system. Clients MUST NOT
  show warnings in the TLS handshake.
- Users MUST NOT be forced to install extra certificates
- The project MUST be able to implement monitoring agent for remote monitoring

## Out-of-scope

Remote monitoring system is not part of the requirements. It will be
implemented in another project.

## Implementations

### MTA

[OpenSMTPD](https://www.opensmtpd.org/) is used as MTA. It is mature enough to
meet the requirements. I originally started my career as a sysadmin with
Postfix, but the project does not have complex requirements.

### IMAP

[dovecot](https://www.dovecot.org/) is used as IMAP server. It has relatively
sane configuration, unlike [`courier`](https://www.courier-mta.org/imap/).

### Authoritative DNS server

[NSD](https://www.nlnetlabs.nl/projects/nsd/about/) is used as authoritative
DNS server.

## Environments

### `virtualbox`

The default environment for development.

The environment has one VM.

### `staging`

The staging environment for pre-release. The environment is used to deploy the
project on AWS EC2. The VPC is same one for the `prod` environment.

The environment has one EC2 instance.

### `prod`

The production environment.

The environment has one EC2 instance.
