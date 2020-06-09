#
# XXX is it possible to replace this script with a logrotate conf and a
# logging.properties that does not try to do its own log rotation?
#
# @summary
#   Install /etc/ccs files.
#
# @api private
class ccs_software::log {
  assert_private()

  $file = 'ccs-log-compress'

  $archive = $::site ? { 'slac' => 'm', default => 'n', }

  file { "/etc/cron.daily/${file}":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp("${module_name}/log/${file}", {'archive' => $archive}),
  }
}
