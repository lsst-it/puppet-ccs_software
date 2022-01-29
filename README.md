# ccs_software

[![Build Status](https://travis-ci.com/lsst-it/puppet-ccs_software.svg?branch=master)](https://travis-ci.com/lsst-it/puppet-ccs_software)

## Table of Contents

1. [Overview](#overview)
1. [Description](#description)
1. [Setup - The basics of getting started with ccs_software](#setup)
    * [What ccs_software affects](#what-ccs_software-affects)
    * [Setup requirements](#setup-requirements)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)

## Overview

This module manages *installation*s of Camera Control System (CCS) software.

## Description

The ccs_software module can optionally manage one or more *installation*s.

## Setup

### What ccs_software affects

* `install.py` script
* ccs /scripts/
* `/lsst` link
* clone(s) of the package-list repo
* ccs `etc` directory
* ccs `log` directory
* [optional] /installations/ of ccs software
* [optional] systemd service units for ccs applications

### Setup Requirements

* `ccs` and `ccsadm` user accounts
* The systemd service units created by this module require `java` to be installed on the system.  See [`java_artisanal`])https://github.com/lsst-it/puppet-java_artisanal)

## Usage

### Absolute Minimal Example / If you want to manually create installations

When the `ccs_software` class is included with no parameters it will create directories, install the `install.py` script, etc. but it *will not* create a CCS *installation*.

```puppet
accounts::user { 'ccs': }
accounts::user { 'ccsadm': }
include ccs_software
```

### Example profile

This is an example of minimal
[profile](https://puppet.com/docs/pe/latest/the_roles_and_profiles_method.html)
that provides the requirements listed in [Setup
requirements](#setup-requirements).  The intent is that the majority of
configuration to the `ccs_software` class be provided via hiera data.

```puppet
class profile::ccs::common {
  include ccs_software
  include accounts
  include java_artisanal

  Class['java_artisanal']
  -> Class['ccs_software']

  accounts::user { 'ccs':
    uid => 62000,
    gid => 62000,
  }
  accounts::user { 'ccsadm':
    uid => 62001,
    gid => 62001,
  }
}
```

### Installation(s)

This example creates two installations at the paths `/opt/lsst/ccs/master` and
`/opt/lsst/ccs/e4a8224`.  Where `master` and `e4a8224` are refs in the
[`lsst-camera-dh/dev-package-lists`](https://github.com/lsst-camera-dh/dev-package-lists).

```yaml
---
classes:
  - "profile::ccs::common"

ccs_software::hostname: "comcam-mcm"  # not required if `comcam-mcm` is the real hostname
ccs_software::env: "ComCam"
ccs_software::installations:
  master: {}
  e4a8224: {},
```

The literal invocations of the `install.py` command would be something like:

```bash
/opt/lsst/release/bin/install.py --ccs_inst_dir /opt/lsst/ccs/master /opt/lsst/ccsadm/package-lists/master/ComCam/comcam-mcm/ccsApplications.txt
```

and

```bash
/opt/lsst/release/bin/install.py --ccs_inst_dir /opt/lsst/ccs/e4a8224 /opt/lsst/ccsadm/package-lists/e4a8224/ComCam/comcam-mcm/ccsApplications.txt
```

Note that a separate clone of the `dev-package-lists` repo is created for each *installation*.

### Service(s)

This example will create a systemd service unit named `comcam-mcm` that
executes `/opt/lsst/ccs/dev/bin/comcam-mcm`.

```yaml
classes:
  - "profile::ccs::common"

ccs_software::env: "ComCam"
ccs_software::installations:
  e4a8224:
    aliases:
      - "dev"
ccs_software::services:
  dev:
    - "comcam-mcm"
```

### Desktop

```yaml
classes:
  - "profile::ccs::common"

ccs_software::desktop: true  # default is false
```

### Multiple Installations sharing a git clone

This may be an efficiency optimization for simulating a large number of hosts on
a single node.

```yaml
---
classes:
  - "profile::ccs::common"

ccs_software::base_path: "/opt/lsst"
ccs_software::env: "ComCam"
ccs_software::installations:
  test-mcm:
    repo_path: "%{lookup('ccs_software::base_path')}/ccsadm/package-lists/e4a8224"
    repo_ref: "e4a8224"
    hostname: "comcam-mcm"
  test-fp:
    repo_path: "%{lookup('ccs_software::base_path')}/ccsadm/package-lists/e4a8224"
    repo_ref: "e4a8224"
    hostname: "comcam-fp01"
ccs_software::services:
  test-mcm:
    - "comcam-mcm"
  test-fp:
    - "comcam-fp01"
```

### Force git clone update

In the event that a git clone has local changes, and the `vcsrepo` type is
having trouble updating it, setting the `force_git` flag will cause the clones
to be **deleted** and re-cloned on every puppet run.  This flag should generally
only be set temporarily to resolve a known issue.

```yaml
---
classes:
  - "profile::ccs::common"

ccs_software::env: "ComCam"
ccs_software::force_git: true
ccs_software::installations:
  master: {}
```

### Pedantic Example

```yaml
---
classes:
  - "profile::ccs::common"

ccs_software::base_path: "/opt/lsst"
ccs_software::etc_path: "/etc/ccs"
ccs_software::log_path: "/var/log/ccs"
ccs_software::user: "ccs"
ccs_software::group: "ccs"
ccs_software::adm_user: "ccsadm"
ccs_software::adm_group: "ccsadm"
ccs_software::pkglist_repo_url: "https://github.com/lsst-camera-dh/dev-package-lists" # overriden in installations hash
ccs_software::release_repo_url: "https://github.com/lsst-it/release"
ccs_software::release_repo_ref: "IT-2233/working"
ccs_software::env: ~ # overriden in installations hash
ccs_software::hostname: "%{lookup(facts.hostname)}" # overidden in installations hash
ccs_software::desktop: false
ccs_software::git_force: false
ccs_software::installations:
  test1:
    repo_path: "%{lookup('ccs_software::base_path')}/ccsadm/package-lists/test1"
    repo_url: "https://github.com/lsst-camera-dh/dev-package-lists"
    repo_ref: "e4a8224"
    env: "ComCam"
    hostname: "comcam-mcm"
    aliases:
      - "dev"
  test42:
    repo_path: "%{lookup('ccs_software::base_path')}/ccsadm/package-lists/test42"
    repo_url: "https://github.com/lsst-camera-dh/dev-package-lists"
    repo_ref: "e4a8224"
    env: "IR2"
    hostname: "lsst-dc01"
    aliases:
      - "prod"
ccs_software::services:
  dev:
    - "comcam-mcm"
  prod:
    - "lsst-dc01"
```

## Reference

See [REFERENCE](REFERENCE.md).
