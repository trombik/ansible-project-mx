# Testing

Tests MUST be automated in projects. This document describes how tests in
projects are implemented.

## General

A commit SHOULD have a test for the change.

A test SHOULD be written, and commit, with the change of its subject.

A test MUST have its subject and description documented.

Reviewers SHOULD reject PRs, or ask changes, when a commit does not have
tests.

## Type of tests

In project testing, there are two types of tests, static and destructive.

### Static tests

A static test is a test that does not affect subjects it tests.

A static test MUST NOT affect, or change, the state of its subjects.

A static test MUST have idempotency, generating same results when the subjects
are identical.

Static tests MUST be kept under `tests/serverspec`.

### Destructive tests

A destructive test is a test that changes the state of the subjects that it
tests.

A destructive test MAY affect, or change, the state of its subjects.

A destructive test MAY have idempotency.

Destructive tests MUST NOT be performed automatically in production systems.

Destructive tests MUST implement protections to prevent users from automating
them in `prod` environment, such as asking confirmation from users.

Destructive tests MUST be kept under `tests/integration`.

## Testing methodology

The following items SHOULD be used when the subject is its implementation:

- Ruby language and `rspec`
- `serverspec` for static tests
- protocol implementations in standard ruby, provided by gems, and/or
  `serverspec`, for destructive tests
- [Better Specs](http://www.betterspecs.org/) as a reference
- `rubocop` for linting

Packaged applications, such as ruby `gem`, `npm` packages, or platform
package, SHOULD be used when the subject is content of the repository.

Tests MUST be performed in `test:travis` target in the `Rakefile`.

## Tests in projects

### Running tests

Tests MUST have identical command to perform them regardless of environments.

### Subjects

Tests in a project MUST test implementation details of the project, and
the logic behind the implementations.

Tests in a project SHOULD test contents of the project repository where
possible, such as spellings in documents.

### Environments

Every environment MUST have tests, static and destructive.

Tests in a project MUST be identical other then environmental differences.

Subjects in a test MUST be identical other than environmental differences.

Environmental differences SHOULD NOT be hard-coded in tests. Group variables
SHOULD be used where possible.

See also [Environment.md](Environment.md).

### Secret information

Secret information, such as credentials, secret keys, and intellectual
properties, SHOULD NOT be used in tests, other than the `prod` environment.
When secret information is required in tests, fake data, or encrypted data by
`ansible-vault` SHOULD be used.

Secret information MUST NOT be logged in test logs.

### Roles under `roles`

Roles under `roles` directory must be tested.

### Roles from `galaxy`

Roles under `roles.galaxy` MUST be tested independently from the project.
Usually, in their development process.

In project, users MAY tests the roles.
