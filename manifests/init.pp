class ccs_software(
  Hash[String, Hash] $installations    = {},
  String             $base_path        = '/opt/lsst',
  String             $user             = 'ccs',
  String             $group            = 'ccs',
  String             $pkglist_repo_url = 'https://github.com/lsst-camera-dh/dev-package-lists',
  String             $release_repo_url = 'https://github.com/lsst-camera-dh/release',
  String             $release_repo_ref = 'master',
  Optional[String]   $env              = undef,
  Optional[String]   $hostname         = $facts['hostname'],
) {
  $ccs_path     = "${base_path}/ccs"
  $ccsadm_path  = "${base_path}/ccsadm"
  $pkglist_path = "${ccsadm_path}/package-lists"
  $release_path = "${ccsadm_path}/release"
  $install_bin  = "${release_path}/bin/install.py"

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
    source   => $release_repo_url,
    revision => $release_repo_ref,
    user     => $user,
  }

  $installations.each |String $i, Hash $conf| {
    # create a new dev-packages clone for each installation
    $clone_path = $conf['repo_path'] ? {
      undef   => "${pkglist_path}/${i}",
      default => $conf['repo_path'],
    }
    # use $pkglist_repo_url as the default package-lists repo url
    $repo = $conf['repo_url'] ? {
      undef   => $pkglist_repo_url,
      default => $conf['repo_url'],
    }
    # use installation name as the git ref
    $ref = $conf['repo_ref'] ? {
      undef   => $i,
      default => $conf['repo_ref'],
    }

    # ensure the vcsrepo to allow the same clone path to be path of multiple installations
    ensure_resource('vcsrepo', $clone_path, {
      ensure   => latest,
      provider => git,
      source   => $repo,
      revision => $ref,
      user     => $user,
      notify   => Exec["install.py of ${i} installation"],
    })

    # create installation
    $installation_path = "${ccs_path}/${i}"
    $_real_env = $conf['env'] ? {
      undef   => $env,
      default => $conf['env'],
    }
    $_real_hostname = $conf['hostname'] ? {
      undef   => $hostname,
      default => $conf['hostname'],
    }

    if (empty($_real_env)) {
      fail('installation has does not have a env key and the $env param is not set')
    }
    if (empty($_real_hostname)) {
      fail('installation has does not have a hostname key and the $hostname param is not set')
    }

    $ccsapps_path = "${clone_path}/${_real_env}/${_real_hostname}/ccsApplications.txt"

    exec { "install.py of ${i} installation":
      command   => "${install_bin} --ccs_inst_dir ${installation_path} ${ccsapps_path}",
      creates   => $installation_path,
      user      => $user,
      group     => $group,
      tries     => 3,
      logoutput => true,
    }
  }
}
