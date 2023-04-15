#
# @summary
#   Manages ccs systemd service units
#
# @api private
class ccs_software::service {
  assert_private()

  $ccs_software::services.each |String $alias, Array[Variant[String, Hash]] $services| {
    $services.each |$svc| {
      if $svc =~ Hash {
        $service_name = $svc['name']
        $cmd_base = $service_name
        $hash_cmd = $svc['cmd']
        $hash_user = $svc['user']
        $hash_group = $svc['group']
        $hash_workdir = $svc['workdir']
        $service_env = $svc['env']
      } else {
        $service_name = $svc
        $cmd_base = $svc
        $hash_cmd = ''
        $hash_user = ''
        $hash_group = ''
        $hash_workdir = ''
        $service_env = undef
      }
      $cmd = "${ccs_software::ccs_path}/${alias}/bin/${cmd_base}"
      $service_cmd = pick($hash_cmd,$cmd)
      $service_user = pick($hash_user,$ccs_software::user)
      $service_group = pick($hash_group,$ccs_software::group)
      $service_workdir = pick($hash_workdir,$ccs_software::_real_service_workdir)
      $epp_vars = {
        desc    => "CCS ${service_name} service",
        user    => $service_user,
        group   => $service_group,
        cmd     => $service_cmd,
        workdir => $service_workdir,
        env     => $service_env,
      }

      systemd::unit_file { "${service_name}.service":
        content => epp("${module_name}/service/ccs.service.epp", $epp_vars),
      }
      -> service { $service_name:
        enable => true,
      }

      ## NB this uses $ccs_software::user even if the service runs
      ## under a different user.
      $epp_sudo_vars = {
        service => $service_name,
        user    => $ccs_software::user,
      }

      sudo::conf { "ccs-service-${service_name}":
        content => epp("${module_name}/sudo/ccs.sudo.epp", $epp_sudo_vars),
      }
    }
  }

  $email_helper = 'systemd-email'

  file { "/usr/local/libexec/${email_helper}":
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "puppet:///modules/${module_name}/service/${email_helper}",
  }

  $email_config = 'systemd-email'
  $email_service = 'status-email-user@.service'
  $envfile = "${ccs_software::etc_path}/${email_config}"

  systemd::unit_file { $email_service:
    content => epp("${module_name}/service/${email_service}.epp", { 'envfile' => $envfile }),
  }

  file { $envfile:
    ensure  => file,
    owner   => $ccs_software::adm_user,
    group   => $ccs_software::adm_group,
    mode    => '0644',
    content => epp("${module_name}/service/${email_config}.epp", { 'email' => $ccs_software::service_email }),
  }
}
