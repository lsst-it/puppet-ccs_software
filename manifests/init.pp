class ccs_software(
  Hash[String, Hash]          $installations    = {},
  Hash[String, Array[String]] $services         = {},
  Stdlib::Absolutepath        $base_path        = '/opt/lsst',
  Stdlib::Absolutepath        $etc_path         = '/etc/ccs',
  Stdlib::Absolutepath        $log_path         = '/var/log/ccs',
  String                      $user             = 'ccs',
  String                      $group            = 'ccs',
  String                      $adm_user         = 'ccsadm',
  String                      $adm_group        = 'ccsadm',
  Stdlib::HTTPUrl             $pkglist_repo_url = 'https://github.com/lsst-camera-dh/dev-package-lists',
  Stdlib::HTTPUrl             $release_repo_url = 'https://github.com/lsst-it/release',
  String                      $release_repo_ref = 'IT-2233/working',
  Optional[String]            $env              = undef,
  Optional[String]            $hostname         = $facts['hostname'],
  Boolean                     $desktop          = false,
) {
  $ccs_path    = "${base_path}/ccs"
  $ccsadm_path = "${base_path}/ccsadm"

  contain ccs_software::pre
  contain ccs_software::install
  contain ccs_software::config
  contain ccs_software::service
  contain ccs_software::log # does not need to be ordered

  Class['::ccs_software::pre']
  -> Class['::ccs_software::install']
  -> Class['::ccs_software::config']
  -> Class['::ccs_software::service']

  if ($desktop) {
    contain ccs_software::desktop
  }
}
