# Reference
<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

**Classes**

_Public Classes_

* [`ccs_software`](#ccs_software): Installs and configures CCS software

_Private Classes_

* `ccs_software::config`: Install /etc/ccs files.
* `ccs_software::desktop`: Add desktop menu entries for CCS apps.
* `ccs_software::install`: Install ccs software.
* `ccs_software::log`: Install /etc/ccs files.
* `ccs_software::pre`: Install ccs software prerequisites
* `ccs_software::service`: Manages ccs systemd service units

## Classes

### ccs_software

Installs and configures CCS software

#### Parameters

The following parameters are available in the `ccs_software` class.

##### `installations`

Data type: `Hash[String, Hash]`

Hash of hashes which describes one or more CCS "installations" to manage.

Options:

* **name-of-installation** `String`: The top level hash keys are the name of the installation. Eg., `foo` would
create the installation `/opt/lsst/ccs/<foo>`.

Supported keys in nested hashes:

- repo_path - Overrides the default path to package list repo clone for this installation.
- repo_url - Overrides the `pkglist_repo_url` param for this installation.
- repo_ref - Overrides the `pkglist_repo_ref` param for this installation.
- env - Overides the `env` param for this installation.
- hostname - Overides the `hostname` param for this installation.
- aliases - [Array] of "alias" links to create for the current installation.

Default value: {}

##### `services`

Data type: `Hash[String, Array[String]]`

Hash of Arrays of services to create systemd service units for.

Options:

* **name-of-alias** `String`: [Array] of service names/service executables (links under /opt/lsst/<alias>/bin/)

Default value: {}

##### `base_path`

Data type: `Stdlib::Absolutepath`

Base path for [all] CCS installations.

Default value: '/opt/lsst'

##### `etc_path`

Data type: `Stdlib::Absolutepath`

Path to global CCS configuration files.

Default value: '/etc/ccs'

##### `log_path`

Data type: `Stdlib::Absolutepath`

Path to CCS log files.

Default value: '/var/log/ccs'

##### `user`

Data type: `String`

Name of the role user under which CCS services will be run and the owner of config files

Default value: 'ccs'

##### `group`

Data type: `String`

Name of the role group

Default value: 'ccs'

##### `adm_user`

Data type: `String`

Name of the admin role user which owns many of the installed files

Default value: 'ccsadm'

##### `adm_group`

Data type: `String`

Name of the admin role group

Default value: 'ccsadm'

##### `pkglist_repo_url`

Data type: `Stdlib::HTTPUrl`

URL of the git repo to use for `install.py` package lists by default.  This
may be overriden in a `installations` hash with the `repo_url` key.

Default value: 'https://github.com/lsst-camera-dh/dev-package-lists'

##### `release_repo_url`

Data type: `Stdlib::HTTPUrl`

URL of the repo which contains the `install.py` script.

Default value: 'https://github.com/lsst-it/release'

##### `release_repo_ref`

Data type: `String`

`install.py` git repo ref.

Default value: 'IT-2233/working'

##### `env`

Data type: `Optional[String]`

Name of the package list environment.  Eg., `ComCam`.  This may be
overriden in a `installation` hash with the `env` key.

Default value: `undef`

##### `hostname`

Data type: `Optional[String]`

The "short" hostname used to select the installation set in a package lists repo.

Default value: $facts['hostname']

##### `desktop`

Data type: `Boolean`

Install desktop shortcuts.

Default value: `false`
