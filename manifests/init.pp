class ccs_software(
  Hash[String, Hash]  $envs      = {},
  String              $base_path = '/opt/lsst',
  String              $user      = 'ccs',
  String              $group     = 'ccs',
) {
  $ccs_path     = "${base_path}/ccs"
  $ccsadm_path  = "${base_path}/ccsadm"
  $pkglist_path = "${ccsadm_path}/dev-package-lists"

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
}
