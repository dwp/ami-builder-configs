unt_option_dev_shm_noexec will fail (we exempt partitioning)
# OpenSCAP Rule ID mount_option_dev_shm_nosuid will fail (we exempt partitioning)
# OpenSCAP Rule ID mount_option_var_tmp_bind will fail (we exempt partitioning)
# OpenSCAP Rule ID mount_option_dev_shm_node will fail (we exempt partitioning)
# OpenSCAP Rule ID rsyslog_remote_loghost will fail (we offload logs to CloudWatch instead)
# OpenSCAP Rule ID selinux_confinement_of_daemons will fail (we have verified the output the query generates)
# OpenSCAP Rule ID grub_legacy_password will fail (will cause Instance not to boot)
# OpenSCAP Rule ID rpm_verify_permissions will fail (CIS explicitly sets the perms on these files)
# OpenSCAP Rule ID rpm_verify_hashes will fail (we have verified the output the query generates)
# OpenSCAP Rule ID mount_option_tmp_nodev, mount_option_tmp_noexec, mount_option_tmp_nosuid, mount_option_var_tmp_bind (exemption as we don't have sep partition for /tmp)
# OpenSCAP Rule ID rsyslog_files_permissions will fail (cloud-init appears to be setting back to 644)
# OpenSCAP Rule ID service_ip6tables_enabled will fail (we are not using ipv6)
# OpenSCAP Rule ID sysctl_net_ipv6_conf_default_accept_ra will fail (we are not using ipv6)
# OpenSCAP Rule ID sysctl_net_ipv6_conf_default_accept_redirects will fail (we are not using ipv6)


# OpenSCAP Rule ID ensure_logrotate_activated
# CIS 4.3 - Ensure logrotate is configured
sed -i 's/^weekly/daily/' /etc/logrotate.conf



# OpenSCAP Rule ID service_ip6tables_enabled
#service ip6tables stop
#chkconfig ip6tables off

# OpenSCAP Rule ID umask_for_daemons
sed -i 's/^umask 022/umask 027/' /etc/init.d/functions
