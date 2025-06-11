#
# @summary Installs and configures CCS software
#
# @param installations
#   Hash of hashes which describes one or more CCS "installations" to manage.
#
# @option installations [String] name-of-installation
#
#   The top level hash keys are the name of the installation. Eg., `foo` would
#   create the installation `/opt/lsst/ccs/<foo>`.
#
#   Supported keys in nested hashes:
#
#   - repo_path - Overrides the default path to package list repo clone for this installation.
#   - repo_url - Overrides the `pkglist_repo_url` param for this installation.
#   - repo_ref - Overrides the `pkglist_repo_ref` param for this installation.
#   - env - Overides the `env` param for this installation.
#   - hostname - Overides the `hostname` param for this installation.
#   - aliases - [Array] of "alias" links to create for the current installation.
#
# @param service_workdir
#   CWD for services
#
# @param services
#   Hash of Arrays of services to create systemd service units for.
#
# @option services [String] name-of-alias
#   [Array] of service names/service executables (links under /opt/lsst/<alias>/bin/)
#   Alternatively, array element can also be a hash of the form
#   { name: "h2db", key: "value", ... }
#   Allowed keys: cmd, user, group, workdir, env, enable.
#   Values specify the associated service file values/state.
#
# @param base_path
#   Base path for [all] CCS installations.
#
# @param etc_path
#   Path to global CCS configuration files.
#
# @param log_path
#   Path to CCS log files.
#
# @param user
#   Name of the role user under which CCS services will be run and the owner of config files
#
# @param group
#   Name of the role group
#
# @param adm_user
#   Name of the admin role user which owns many of the installed files
#
# @param adm_group
#   Name of the admin role group
#
# @param influx_url
#   String giving URL of the influxDB server.
#
# @param influx_name
#   String giving name of the influxDB instance.
#
# @param influx_username
#   Sensitive string giving influxDB username.
#
# @param influx_password
#   Sensitive string giving influxDB password.
#
# @param apc_pdu
#   True to install APC PDU configuration.
#
# @param apc_pdu_username
#   Sensitive string giving APC PDU username.
#
# @param apc_pdu_password
#   Sensitive string giving APC PDU password.
#
# @param kafka_files
#   Optional hash of kafka properties files and associated values. Eg:
#     data-int:
#       bootstrap_url: "bootstrap_url"
#       registry_url: "registry_url"
#
# @param kafka_auths
#   Optional (but required for each key of kafka_files) hash of kafka
#   files and the associated username and password. Eg:
#     data-int:
#       - "user"
#       - "pass"
#
# @param service_email
#   String giving email address (or comma separated addresses) to
#   receive change of service status emails from systemd.
#
# @param pkglist_repo_url
#   URL of the git repo to use for `install.py` package lists by default.  This
#   may be overriden in a `installations` hash with the `repo_url` key.
#
# @param release_repo_url
#   URL of the repo which contains the `install.py` script.
#
# @param release_repo_ref
#   `install.py` git repo ref.
#
# @param env
#   Name of the package list environment.  Eg., `ComCam`.  This may be
#   overriden in a `installation` hash with the `env` key.
#
# @param hostname
#   The "short" hostname used to select the installation set in a package lists repo.
#
# @param desktop
#   Install desktop shortcuts.
#
# @param git_force
#   Force the update of managed git clones. This is done by passing `force =>
#   true` to `vcsrepo` type resources.
#
# @param global_properties
#    Array of extra strings to add to the ccsGlobal.properties file.
#
# @param udp_properties
#    Array of extra strings to add to the udp_ccs.properties file.
#
class ccs_software (
  Hash[String, Hash]          $installations           = {},
  Hash[String, Array[Variant[String, Hash]]] $services = {},
  Optional[String]            $service_workdir         = undef,
  Stdlib::Absolutepath        $base_path               = '/opt/lsst',
  Stdlib::Absolutepath        $etc_path                = '/etc/ccs',
  Stdlib::Absolutepath        $log_path                = '/var/log/ccs',
  String                      $user                    = 'ccs',
  String                      $group                   = 'ccs',
  String                      $adm_user                = 'ccsadm',
  String                      $adm_group               = 'ccsadm',
  String[1]                   $influx_url              = 'https://camera-influxdb.dev.lsst.org:443',
  String[1]                   $influx_name             = 'grafana',
  Sensitive[String[1]]        $influx_username         = Sensitive('user'),
  Sensitive[String[1]]        $influx_password         = Sensitive('pass'),
  Boolean                     $apc_pdu                 = false,
  Sensitive[String[1]]        $apc_pdu_username        = Sensitive('user'),
  Sensitive[String[1]]        $apc_pdu_password        = Sensitive('pass'),
  Hash[String, Hash]          $kafka_files             = {},
  Hash[String, Array[Variant[Sensitive[String],String]]] $kafka_auths  = {},
  String                      $service_email           = 'root@localhost',
  Stdlib::HTTPUrl             $pkglist_repo_url        = 'https://github.com/lsst-camera-dh/dev-package-lists',
  Stdlib::HTTPUrl             $release_repo_url        = 'https://github.com/lsst-it/release',
  String                      $release_repo_ref        = 'IT-4348/python3',
  Optional[String]            $env                     = undef,
  Optional[String]            $hostname                = $facts['networking']['hostname'],
  Boolean                     $desktop                 = false,
  Boolean                     $git_force               = false,
  Array[String]               $global_properties       = [],
  Array[String]               $udp_properties          = [],
) {
  $ccs_path    = "${base_path}/ccs"
  $ccsadm_path = "${base_path}/ccsadm"

  $_real_service_workdir = $service_workdir ? {
    undef   => "/home/${user}",
    default => $service_workdir,
  }

  contain ccs_software::pre
  contain ccs_software::install
  contain ccs_software::config
  contain ccs_software::service
  contain ccs_software::log # does not need to be ordered

  Class['ccs_software::pre']
  -> Class['ccs_software::install']
  -> Class['ccs_software::config']
  -> Class['ccs_software::service']

  if ($desktop) {
    contain ccs_software::desktop
  }
}
