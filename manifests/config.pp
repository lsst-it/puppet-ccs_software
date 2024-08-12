#
# @summary
#   Install /etc/ccs files.
#
# @api private
class ccs_software::config {
  assert_private()

  $etc_path = $ccs_software::etc_path
  ## Next two use the "unique" merge strategy in hieradata/org/lsst.yaml.
  $global_properties = $ccs_software::global_properties
  $udp_properties = $ccs_software::udp_properties

  ## Hash of templates and any arguments they take.
  $etc_files = {
    'logging.properties' => {},
    'ccsGlobal.properties' => {
      'global_properties' => $global_properties,
    },
    'udp_ccs.properties' => {
      'hostname' => $trusted['certname'],
      'udp_properties' => $udp_properties,
    },
    ## File needs to be readable by anyone who can run a CCS process,
    ## ie anyone who can login.
    'influxDb.properties' => {
      'url'      => $ccs_software::influx_url,
      'name'     => $ccs_software::influx_name,
      'username' => $ccs_software::influx_username,
      'password' => $ccs_software::influx_password,
    },
  }

  $etc_files.each |$file, $epp_vars| {
    file { "${etc_path}/${file}":
      ensure  => file,
      owner   => $ccs_software::adm_user,
      group   => $ccs_software::adm_group,
      mode    => '0664',
      content => epp("${module_name}/config/${file}.epp", $epp_vars),
    }
  }
}
