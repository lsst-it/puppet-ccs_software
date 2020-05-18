class ccs_software(
  Hash[String, Hash] $envs         = {},
  String             $base_path    = '/opt/lsst',
  String             $user         = 'ccs',
  String             $group        = 'ccs',
  String             $pkglist_repo = 'https://github.com/lsst-camera-dh/dev-package-lists',
  String             $release_repo = 'https://github.com/lsst-camera-dh/release',
  String             $release_ref  = 'master',
) {
  $ccs_path     = "${base_path}/ccs"
  $ccsadm_path  = "${base_path}/ccsadm"
  $pkglist_path = "${ccsadm_path}/package-lists"
  $release_path = "${ccsadm_path}/release"

  $dirs = [
    $base_path,
    $ccs_path,
    $ccsadm_path,
    $pkglist_path,
  ]

  file { $dirs:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
    backup => false,
  }

  # provides bin/install.py
  vcsrepo { $release_path:
    ensure   => latest,
    provider => git,
    source   => $release_repo,
    revision => $release_ref,
    user     => $user,
  }

  $envs.each |String $e, Hash $conf| {
    # create a new clone for each env
    $clone_path = $conf['path'] ? {
      undef   => "${pkglist_path}/${e}",
      default => $conf['path'],
    }
    # use $pkglist_repo as the default repo url
    $repo = $conf['repo'] ? {
      undef   => $pkglist_repo,
      default => $conf['repo'],
    }
    # use env name as the git ref
    $ref = $conf['ref'] ? {
      undef   => $e,
      default => $conf['ref'],
    }

    # ensure the vcsrepo to allow the same clone path to be path of multiple envs
    ensure_resource('vcsrepo', $clone_path, {
      ensure   => latest,
      provider => git,
      source   => $repo,
      revision => $ref,
      user     => $user,
    })
  }
}
