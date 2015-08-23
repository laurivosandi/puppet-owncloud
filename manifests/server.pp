
define owncloud::server(
    $hostname = "$title",
    $ensure = 'enabled',
    $ssl_certificate = undef,
    $ssl_certificate_key = undef,
    $client_max_body_size = "10G"
) {
    case $ensure {
        'enabled': {
            file { "/etc/nginx/sites-enabled/$title":
               ensure => 'link',
               target => "/etc/nginx/sites-available/$title",
            }
            ~>
            Service["nginx"]
        }
        'disabled', 'absent', 'purged': {
            file { "/etc/nginx/sites-enabled/$title":
                ensure => absent
            }
            ~>
            Service["nginx"]
        }
    }

    package { "sudo": ensure => present }
    ->
    file { "/usr/local/bin/occ":
        ensure => file,
        mode => 755,
        owner => root,
        group => root,
        content => "#!/bin/bash\nsudo -u www-data php5 /var/www/owncloud/occ \"\$@\"\n"
    }

    if $lsbdistcodename == "trusty" {
        # Upgrade broken php5-apc
        apt::ppa { "ppa:ondrej/php5-5.6": }
    }

    if $lsbdistcodename == "wheezy" {
        apt::hold { "php5-common": version => "5.4.36-0+deb7u1" }
    }

    $suffix = $lsbdistcodename ? {
        "vivid" => "xUbuntu_15.04",
        "utopic" => "xUbuntu_14.10",
        "trusty" => "xUbuntu_14.04",
        "precise" => "xUbuntu_12.04",
        "wheezy" => "Debian_7.0",
        "jessie" => "Debian_8.0"
    }

    apt::source { "owncloud":
        key => "F9EA4996747310AE79474F44977C43A8BA684223",
        key_server => "keyserver.ubuntu.com",
        location => "http://download.opensuse.org/repositories/isv:/ownCloud:/community/$suffix",
        release => " ",
        repos => "/",
        include_src => false
    }
    ~>
    Exec["apt_update"]
    ->
    package { "owncloud": ensure => installed }
    service { "apache2": ensure => stopped, enable => false } ->
    package { "nginx": ensure => installed }
    package { "php5-fpm": ensure => installed }
    package { "php5-ldap": ensure => installed }
    package { "php5-mysql": ensure => installed }
    package { "php5-pgsql": ensure => installed }
    ->
    file { "/etc/nginx/sites-available/$hostname":
        ensure => present,
        owner => root,
        group => root,
        mode => 0644,
        content => template("owncloud/nginx-site.erb")
    }
    ->
    file_line { "php5-fpm-upload-max-filesize":
        path => "/etc/php5/fpm/php.ini",
        match => "^upload_max_filesize =",
        line => "upload_max_filesize = $client_max_body_size"
    }
    ->
    file_line { "php5-fpm-post-max-size":
        path => "/etc/php5/fpm/php.ini",
        match => "^post_max_size =",
        line => "post_max_size = $client_max_body_size"
    }
    ->
    file_line { "php5-cli-always-populate-raw-post-data":
        path => "/etc/php5/cli/php.ini",
        match => ";always_populate_raw_post_data ",
        line => "always_populate_raw_post_data = -1"
    }
    ->
    file_line { "php5-fpm-always-populate-raw-post-data":
        path => "/etc/php5/fpm/php.ini",
        match => ";always_populate_raw_post_data ",
        line => "always_populate_raw_post_data = -1"
    }
    ->
    service { "nginx": ensure => running, enable => true }
}

