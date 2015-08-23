
define owncloud::ldap(
    $agent_dn,
    $agent_password,
    $uri = "ldap://$title",
    $base = inline_template("<%= scope.lookupvar('title').split('.').map{|j| 'dc='+j}.join(',') %>"),
    $base_groups = $base,
    $base_users = $base,
    $ensure = "present",
    $expert_username_attribute = "sAMAccountName",
    $expert_uuid_user_attribute = $expert_username_attribute,
    $email_allowed = false,
    $login_filter = '(&(objectClass=user)(|($expert_username_attribute=%uid)(mail=%uid)))',
    $email_attribute = 'mail',
    $login_filter_email = true,
    $login_filter_attributes = "$expert_username_attribute",
    $port = undef,
    $user_filter = '',
    $user_filter_object_class = 'user',
    $tls_enabled = false,
    $user_display_name = 'displayName',
) {
    file { "/usr/local/bin/occ-ldap-set-config-$title":
        ensure => present,
        mode => 0755,
        group => root,
        owner => root,
        content => template("owncloud/occ-enable-ldap.erb")
    }

    # TODO: Execute script if occ ldap:test-config fails
}
