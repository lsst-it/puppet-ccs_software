#
# @summary
#   Install ccs software.
#
# @api private
class ccs_software::install {
  assert_private()

  $installations    = $::ccs_software::installations
  $base_path        = $::ccs_software::base_path
  $etc_path         = $::ccs_software::etc_path
  $log_path         = $::ccs_software::log_path
  $user             = $::ccs_software::user
  $group            = $::ccs_software::group
  $adm_user         = $::ccs_software::adm_user
  $adm_group        = $::ccs_software::adm_group
  $pkglist_repo_url = $::ccs_software::pkglist_repo_url
  $release_repo_url = $::ccs_software::release_repo_url
  $release_repo_ref = $::ccs_software::release_repo_ref
  $env              = $::ccs_software::env
  $hostname         = $::ccs_software::hostname

  $ccs_path     = "${base_path}/ccs"
  $ccsadm_path  = "${base_path}/ccsadm"
  $pkglist_path = "${ccsadm_path}/package-lists"
  $release_path = "${ccsadm_path}/release"
  $install_bin  = "${release_path}/bin/install.py"

  $dirs = [
    $ccs_path,
    $ccsadm_path,
    $pkglist_path,
  ]

  # the base path should be owned by root
  # try to be nice about sharing the base path with other mods
  ensure_resources('file', {
    $base_path => {
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      backup => false,
    },
    '/lsst'    => {
      ensure => symlink,
      group  => 'root',
      owner  => 'root',
      target => $base_path
    },
    $etc_path  => {
      ensure => directory,
      owner  => $adm_user,
      group  => $adm_group,
      mode   => '2775',
    },
    $log_path  => {
      ensure => directory,
      owner  => 'root',
      group  => $group,
      mode   => '2775',
    },
  })

  file { $dirs:
    ensure => directory,
    owner  => $adm_user,
    group  => $adm_group,
    mode   => '0755',
    backup => false,
  }

  # provides bin/install.py
  vcsrepo { $release_path:
    ensure   => latest,
    provider => git,
    source   => $release_repo_url,
    revision => $release_repo_ref,
    user     => $adm_user,
    require  => File[$ccsadm_path],  # vcsrepo doesn't autorequire its parent dir
  }

  $installations.each |String $i, Hash $conf| {
    $exec_install_title = "install.py ${i}"
    $exec_chown_title = "chown ${i}"

    #
    # create a new dev-packages clone for each installation
    #
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
      ensure   => present,
      provider => git,
      source   => $repo,
      revision => $ref,
      user     => $adm_user,
      notify   => Exec[$exec_install_title],
      require  => File[$pkglist_path],  # vcsrepo doesn't autorequire its parent dir
    })

    #
    # create installation
    #
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
    $etc_path     = "${installation_path}/etc"

    exec { $exec_install_title:
      command   => "${install_bin} --ccs_inst_dir ${installation_path} ${ccsapps_path}",
      creates   => $installation_path,
      user      => $adm_user,
      group     => $adm_group,
      tries     => 3,
      logoutput => true,
      cwd       => $base_path,
      timeout   => 900,
    }
    ~> exec { $exec_chown_title:
      command   => "chown -R -H ${user}:${group} ${etc_path}",
      path      => '/bin:/usr/bin',
      # run only if the etc symlink exists (it may not) and ownership of the
      # link target is out of sync
      onlyif    => "[[ -e ${etc_path} && ${user} != $(stat -L --format='%U' ${etc_path}) ]]",
      provider  => shell,
      logoutput => true,
      cwd       => $base_path,
    }

    #
    # create aliases (if any)
    #
    unless (empty($conf['aliases'])) {
      $conf['aliases'].each |String $a| {
        file { "${ccs_path}/${a}":
          ensure => 'link',
          owner  => $adm_user,
          group  => $adm_group,
          target => $installation_path,
        }
      }
    }
  }
}