#
# @summary
#   Add desktop menu entries for CCS apps.
#
# @api private
class ccs_software::desktop {
  assert_private()

  $dirs = [
    '/etc/xdg/menus',
    '/etc/xdg/menus/applications-merged',
    '/usr/share/desktop-directories',
    '/usr/share/applications',
    '/usr/share/icons',
  ]

  # these dirs are expected to be existing system paths which we shouldn't "own"
  $dirs.each |String $d| {
    ensure_resources('file', {
        $d => {
          ensure => directory,
        },
    })
  }

  $files = [
    '/etc/xdg/menus/applications-merged/lsst.menu',
    '/usr/share/desktop-directories/lsst.directory',
    ## TODO not a great icon.
    '/usr/share/icons/lsst_appicon.png',
  ]

  $files.each |String $file| {
    file { $file:
      ensure => file,
      source => "puppet:///modules/${module_name}/desktop/${basename($file)}",
    }
  }

  $apps = ['console', 'shell']

  $apps.each |String $app| {
    ['prod', 'dev'].each |String $version| {
      $desc = $version ? {
        'prod' => 'production',
        'dev'  => 'development',
      }
      $terminal = $app ? {
        'console' => false,
        'shell'   => true,
      }
      file { "/usr/share/applications/lsst.ccs.${app}.${version}.desktop":
        ensure  => file,
        content => epp("${module_name}/desktop/lsst.ccs.APP.VERSION.desktop.epp", {
            version  => $version,
            app      => $app,
            desc     => $desc,
            terminal => $terminal,
        }),
      }
    }
  }

  include 'dconf'

  ## The dconf module is silent on how one defines a list value,
  ## but by experiment it seems a literal string is needed.
  $faves = [
    'lsst.ccs.console.prod.desktop',
    'lsst.ccs.shell.prod.desktop',
    'firefox.desktop',
    'org.gnome.Nautilus.desktop',
    'yelp.desktop',
    'org.gnome.Terminal.desktop',
  ]

  ## Would be nice if the dconf module did this internally, but no.
  $value = String($faves, '%[a')

  dconf::settings { '00-favorite-apps':
    profile       => 'local',
    settings_hash => {
      'org/gnome/shell' => {
        'favorite-apps' => { 'value' => $value, 'lock' => false },
      },
    },
  }
}
