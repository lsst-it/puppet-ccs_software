#
# @summary
#   Install /etc/ccs/tomcat files.
#
# @api private
class ccs_software::tomcat {
  assert_private()

  $etc_path = $ccs_software::tomcat_rest_etc_path
  $etc_user = 'tomcat'
  $etc_group = $ccs_software::adm_group
  $user = $ccs_software::tomcat_rest_user
  $pass = $ccs_software::tomcat_rest_pass
  $url = $ccs_software::tomcat_rest_url

  ensure_resources('file', {
      $etc_path => {
        ensure => directory,
        owner  => $etc_user,
        group  => $etc_group,
        mode   => '2770',
      },
  })

  ## Hash of templates and any arguments they take.
  $etc_files = {
    'logging.properties' => {},
    'statusPersister.properties' => {
      'user' => $user,
      'pass' => $pass,
      'url'  => $url,
    },
  }

  $etc_files.each |$file, $epp_vars| {
    file { "${etc_path}/${file}":
      ensure  => file,
      owner   => $etc_user,
      group   => $etc_group,
      mode    => '0660',
      content => epp("${module_name}/tomcat/${file}.epp", $epp_vars),
    }
  }
}
