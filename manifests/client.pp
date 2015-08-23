
class owncloud::client {
    if $architecture == "i386" or $architecture == "amd64" {

        $suffix = $lsbdistcodename ? {
            "vivid" => "xUbuntu_15.04",
            "utopic" => "xUbuntu_14.10",
            "trusty" => "xUbuntu_14.04",
            "precise" => "xUbuntu_12.04",
            "wheezy" => "Debian_7.0",
            "jessie" => "Debian_8.0"
        }

        apt::source { "owncloud-client":
            key => "F9EA4996747310AE79474F44977C43A8BA684223",
            key_server => "keyserver.ubuntu.com",
            location => "http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/$suffix",
            release => " ",
            repos => "/",
            include_src => false
        }
        ->
        Package["owncloud-client"]
    }

    package { "owncloud-client": ensure => installed }
    ->
    file_line { "owncloud-client-icon-estonian-translation":
        ensure => present,
        path => "/usr/share/applications/owncloud.desktop",
        line => "Name[et]=ownCloud sünkroniseerimisrakendus"
    }

    # Generate OwnCloud sync status plugin for MATE's Caja file browser
    if defined( Package["python-caja"] ) {
        Package["python-caja"] ->
        Package["owncloud-client"]
        ->
        exec { "generate-caja-sync-plugin":
            command => "/bin/sed -e 's/Nautilus/Caja/g' /usr/share/nautilus-python/extensions/syncstate.py > /usr/share/caja-python/extensions/syncstate.py",
            creates => "/usr/share/caja-python/extensions/caja-qdigidoc.py"
        }
    }
}
