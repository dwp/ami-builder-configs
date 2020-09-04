#!/bin/sh

# Hardens an Amazon Linux AMI according to CIS Amazon Linux Benchmark v2.1.0

set -eEu

echo "#############################################################"
echo "1.1.1.1 Ensure mounting of cramfs filesystems is disabled"
echo "1.1.1.2 Ensure mounting of freevxfs filesystems is disabled"
echo "1.1.1.3 Ensure mounting of jffs2 filesystems is disabled"
echo "1.1.1.4 Ensure mounting of hfs filesystems is disabled"
echo "1.1.1.5 Ensure mounting of hfsplus filesystems is disabled"
echo "1.1.1.6 Ensure mounting of squashfs filesystems is disabled"
echo "1.1.1.7 Ensure mounting of udf filesystems is disabled"
echo "1.1.1.8 Ensure mounting of FAT filesystems is disabled"
echo "3.5.1 Ensure DCCP is disabled"
echo "3.5.2 Ensure SCTP is disabled"
echo "3.5.3 Ensure RDS is disabled"
echo "3.5.4 Ensure TIPC is disabled"
##abk  > /etc/modprobe.d/CIS.conf
##abk  for fs in cramfs freevxfs jffs2 hfs hfsplus squashfs udf vfat \
##abk      dccp sctp rds tipc; do
##abk      echo "install $fs /bin/true" >> /etc/modprobe.d/CIS.conf
##abk  done

echo "#############################################################"
echo "1.1.2 Ensure separate partition exists for /tmp"
echo "Temporary Exemption: we're not sure that partioning provides much value for single-use instances"

echo "#############################################################"
echo "1.1.3 Ensure nodev option set on /tmp partition"
echo "Temporary Exemption: we're not sure that partioning provides much value for single-use instances"

echo "#############################################################"
echo "1.1.4 Ensure nosuid option set on /tmp partition"
echo "Temporary Exemption: we're not sure that partioning provides much value for single-use instances"

echo "#############################################################"
echo "1.1.5 Ensure noexec option set on /tmp partition"
echo "Temporary Exemption: we're not sure that partioning provides much value for single-use instances"

echo "#############################################################"
echo "1.1.6 Ensure separate partition exists for /var"
echo "Temporary Exemption: we're not sure that partioning provides much value for single-use instances"

echo "#############################################################"
echo "1.1.7 Ensure separate partition exists for /var/tmp"
echo "Temporary Exemption: we're not sure that partioning provides much value for single-use instances"

echo "#############################################################"
echo "1.1.8 Ensure nodev option set on /var/tmp partition"
echo "Temporary Exemption: we're not sure that partioning provides much value for single-use instances"

echo "#############################################################"
echo "1.1.9 Ensure nosuid option set on /var/tmp partition"
echo "Temporary Exemption: we're not sure that partioning provides much value for single-use instances"

echo "#############################################################"
echo "1.1.10 Ensure noexec option set on /var/tmp partition"
echo "Temporary Exemption: we're not sure that partioning provides much value for single-use instances"

echo "#############################################################"
echo "1.1.11 Ensure separate partition exists for /var/log"
echo "Temporary Exemption: we're not sure that partioning provides much value for single-use instances"

echo "#############################################################"
echo "1.1.15 Ensure nodev option set on /dev/shm partition"
echo "1.1.16 Ensure nosuid option set on /dev/shm partition"
echo "1.1.17 Ensure noexec option set on /dev/shm partition"
echo "tmpfs /dev/shm tmpfs defaults,nodev,nosuid,noexec 0 0" > /etc/fstab

echo "#############################################################"
echo "1.1.18 Set sticky bit on all world-writable directories"
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | xargs chmod a+t

##abh echo "#############################################################"
##abh echo "1.1.19 Disable Automounting"
##abh echo "2.1.1 Ensure chargen services are not enabled"
##abh echo "2.1.2 Ensure daytime services are not enabled"
##abh echo "2.1.3 Ensure discard services are not enabled"
##abh echo "2.1.4 Ensure echo services are not enabled"
##abh echo "2.1.5 Ensure time services are not enabled"
##abh echo "2.1.6 Ensure rsh server is not enabled"
##abh echo "2.1.7 Ensure talk server is not enabled"
##abh echo "2.1.8 Ensure telnet server is not enabled"
##abh echo "2.1.9 Ensure tftp server is not enabled"
##abh echo "2.1.10 Ensure rsync service is not enabled"
##abh echo "2.1.11 Ensure xinetd is not enabled"
##abh echo "2.2.3 Ensure Avahi Server is not enabled"
##abh echo "2.2.4 Ensure CUPS is not enabled"
##abh echo "2.2.5 Ensure DHCP Server is not enabled"
##abh echo "2.2.6 Ensure LDAP server is not enabled"
##abh echo "2.2.7 Ensure NFS and RPC are not enabled"
##abh echo "2.2.8 Ensure DNS Server is not enabled"
##abh echo "2.2.9 Ensure FTP Server is not enabled"
##abh echo "2.2.10 Ensure HTTP server is not enabled"
##abh echo "2.2.11 Ensure IMAP and POP3 server is not enabled"
##abh echo "2.2.12 Ensure Samba is not enabled"
##abh echo "2.2.13 Ensure HTTP Proxy Server is not enabled"
##abh echo "2.2.14 Ensure SNMP Server is not enabled"
##abh echo "2.2.15 Ensure mail transfer agent is configured for local-only mode"
##abh echo "2.2.16 Ensure NIS Server is not enabled"
##abh echo "Disabling unnecessary services"
##abh echo "Only installed service is rpcbind"
##abh for svc in rpcbind; do
##abh     chkconfig $svc off
##abh done;
##abh
##abh echo "#############################################################"
##abh echo "1.2 Configure Software Updates"
##abh echo "1.2.1 Ensure package manager repositories are configured"
##abh echo "1.2.2 Ensure GPG keys are configured"
##abh echo "1.2.3 Ensure gpgcheck is globally activated"
##abh echo "Exemption: in-life instances require no access to package repositories; they'll be rebuilt from refreshed AMIs"
##abh
##abh echo "#############################################################"
##abh echo "1.3.1 Ensure AIDE is installed"
##abh echo "1.6.2 Ensure SELinux is installed"
##abh echo "2.2.1.1 Ensure time synchronization is in use"
##abh echo "3.4.1 Ensure TCP Wrappers is installed"
##abh echo "3.6.1 Ensure iptables is installed"
##abh echo "4.2.3 Ensure rsyslog or syslog-ng is installed"
##abh echo "Installing required packages"
##abh yum install -y \
##abh   aide \
##abh   libselinux \
##abh   tcp_wrappers \
##abh   iptables \
##abh   rsyslog
##abh
##abh echo "#############################################################"
##abh echo "1.3.1 Ensure AIDE is installed"
##abh aide --init
##abh mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
##abh
##abh echo "#############################################################"
##abh echo "1.3.2 Ensure filesystem integrity is regularly checked"
##abh echo "0 5 * * * root /usr/sbin/aide --check" > /etc/cron.d/99-CIS
##abh
##abh echo "#############################################################"
##abh echo "1.4 Secure Boot Settings"
##abh echo "1.4.1 Ensure permissions on bootloader config are configured"
##abh
##abh echo "#############################################################"
##abh echo "1.4.2 Ensure authentication required for single user mode"
##abh echo "Exemption: AWS instances do not allow access to the bootloader or console when the instance is started."
##abh
##abh echo "#############################################################"
##abh echo "1.4.3 Ensure interactive boot is not enabled"
##abh echo "PROMPT=NO" >> /etc/sysconfig/init
##abh # OpenSCAP Rule ID require_singleuser_auth
##abh echo "SINGLE=/sbin/sulogin" >> /etc/sysconfig/init
##abh
##abh echo "#############################################################"
##abh echo "1.5 Additional process hardening"
##abh echo "1.5.1 Ensure core dumps are restricted"
##abh echo "* hard core 0" > /etc/security/limits.d/CIS.conf
##abh
##abh echo "#############################################################"
##abh echo "1.5.1 Ensure core dumps are restricted"
##abh echo "1.5.3 Ensure address space layout randomization (ASLR) is enabled"
##abh echo "3.1.1 Ensure IP forwarding is disabled"
##abh echo "3.1.2 Ensure packet redirect sending is disabled"
##abh echo "3.2.1 Ensure source routed packets are not accepted"
##abh echo "3.2.2 Ensure ICMP redirects are not accepted"
##abh echo "3.2.3 Ensure secure ICMP redirects are not accepted"
##abh echo "3.2.4 Ensure suspicious packets are logged"
##abh echo "3.2.5 Ensure broadcast ICMP requests are ignored"
##abh echo "3.2.6 Ensure bogus ICMP responses are ignored"
##abh echo "3.2.7 Ensure Reverse Path Filtering is enabled"
##abh echo "3.2.8 Ensure TCP SYN Cookies is enabled"
##abh echo "3.3.1 Ensure IPv6 router advertisements are not accepted"
##abh echo "3.3.2 Ensure IPv6 redirects are not accepted"
##abh echo "Tweaking sysctl knobs"

##abg # OpenSCAP sysctl_net_ipv6_conf_default_accept_ra, sysctl_net_ipv6_conf_default_accept_redirects
##abg cat >> /etc/sysctl.conf << SYSCTL
##abg fs.suid_dumpable = 0
##abg kernel.randomize_va_space = 2
##abg net.ipv4.ip_forward = 0
##abg net.ipv4.conf.all.send_redirects = 0
##abg net.ipv4.conf.default.send_redirects = 0
##abg net.ipv4.conf.all.accept_source_route = 0
##abg net.ipv4.conf.default.accept_source_route = 0
##abg net.ipv4.conf.all.accept_redirects = 0
##abg net.ipv4.conf.default.accept_redirects = 0
##abg net.ipv4.conf.all.secure_redirects = 0
##abg net.ipv4.conf.default.secure_redirects = 0
##abg net.ipv4.conf.all.log_martians = 1
##abg net.ipv4.conf.default.log_martians = 1
##abg net.ipv4.icmp_echo_ignore_broadcasts = 1
##abg net.ipv4.icmp_ignore_bogus_error_responses = 1
##abg net.ipv4.conf.all.rp_filter = 1
##abg net.ipv4.conf.default.rp_filter = 1
##abg net.ipv4.tcp_syncookies = 1
##abg net.ipv6.conf.all.accept_ra = 0
##abg net.ipv6.conf.default.accept_ra = 0
##abg net.ipv6.conf.all.accept_redirects = 0
##abg net.ipv6.conf.default.accept_redirects = 0
##abg SYSCTL
##abg
##abg echo "#############################################################"
##abg echo "1.5.2 Ensure XD/NX support is enabled"
##abg echo "Expect: active"
##abg dmesg | grep NX
##abg
##abg echo "#############################################################"
##abg echo "1.5.4 Ensure prelink is disabled"
##abg echo "1.6.1.4 Ensure SETroubleshoot is not installed"
##abg echo "1.6.1.5 Ensure the MCS Translation Service (mcstrans) is not installed"
##abg echo "2.2.1.1 Ensure time synchronization is in use"
##abg echo "2.2.2 Ensure X Window System is not installed"
##abg echo "2.3.1 Ensure NIS Client is not installed"
##abg echo "2.3.2 Ensure rsh client is not installed"
##abg echo "2.3.3 Ensure talk client is not installed"
##abg echo "2.3.4 Ensure telnet client is not installed"
##abg echo "2.3.5 Ensure LDAP client is not installed"
##abg echo "Removing unneccessary packages"
##abg yum remove -y  \
##abg     prelink \
##abg     setroubleshoot \
##abg     mcstrans \
##abg     xorg-x11* \
##abg     ypbind \
##abg     rsh \
##abg     talk \
##abg     telnet \
##abg     openldap-clients --remove-leaves
##abg
##abg echo "#############################################################"
##abg echo "1.6.1.1 - Ensure SELinux is not disabled in bootloader configuration"
##abg echo "Expect: no setting with selinux=0 or enforcing=0"
##abg
##abg echo "#############################################################"
##abg echo "1.6.1.2 Ensure the SELinux state is enforcing"
##abg echo "1.6.1.3 Ensure SELinux policy is configured"
##abg echo "Configuring SELinux"
##abg # Install pre-requisites
##abg yum install -y \
##abg     selinux-policy \
##abg     selinux-policy-targeted \
##abg     policycoreutils-python

##abe #create config file
##abe cat > /etc/selinux/config << EOF
##abe SELINUX=enforcing
##abe SELINUXTYPE=targeted
##abe EOF
##abe
##abe # Create AutoRelabel
##abe touch /.autorelabel

##abf echo "#############################################################"
##abf echo "1.6.1.6 - Ensure no unconfined daemons exist"
##abf echo "Expect: no output"
##abf ps -eZ | egrep "initrc" | egrep -vw "tr|ps|egrep|bash|awk" | tr ':' ' ' | awk '{ print $NF }'
##abf
##abf
##abf echo "#############################################################"
##abf echo "1.7 Warning Banners"
##abf echo "1.7.1 Command Line Warning Banners"
##abf echo "1.7.1.1 Ensure message of the day is configured properly"
##abf # Ensure /etc/motd contains nothing; we want to display a warning *before* login
##abf # in compliance with DWP norms (see 1.7.1.2 below)
##abf > /etc/motd
##abf
##abf # OpenSCAP Rule ID banner_etc_issue will fail (requires a DOD banner)
##abf echo "#############################################################"
##abf echo "1.7.1.2 Ensure local login warning banner is configured properly"
##abf cat > /etc/issue << BANNER
##abf /------------------------------------------------------------------------------\
##abf |                              ***** WARNING *****                             |
##abf |                                                                              |
##abf | UNAUTHORISED ACCESS TO THIS DEVICE IS PROHIBITED                             |
##abf |                                                                              |
##abf | You must have explicit, authorised permission to access or configure this    |
##abf | device. Unauthorised use of this device is a criminal offence under the      |
##abf | Computer Misuse Act 1990. Unauthorized attempts and actions to access or use |
##abf | this system may result in civil and/or criminal penalties.                   |
##abf |                                                                              |
##abf | All actions performed on this system must be in accordance with the          |
##abf | Department's Acceptable Use Policy and Security Operating Procedures         |
##abf | (SyOps). You must ensure you have read and understand these before           |
##abf | attempting to log  |on to this system. Use of this system constitutes        |
##abf | acceptance by you of the provisions of the SyOPs with immediate effect.      |
##abf |                                                                              |
##abf | All activities performed on this device are logged and monitored.            |
##abf |                                                                              |
##abf | If you do not understand any part of this message then please ask your line  |
##abf | manager for further guidance before proceeding.                              |
##abf \------------------------------------------------------------------------------/
##abf BANNER
##abf
##abf echo "#############################################################"
##abf echo "1.7.1.3 Ensure remote login warning banner is configured properly"
##abf # We don't intend to allow remote logins, but this meets CIS compliance and
##abf # ensures compliance with DWP norms if we do decide to enable remote logins
##abf cp /etc/issue /etc/issue.net
##abf
##abf echo "#############################################################"
##abf echo "1.7.1.4 Ensure permissions on /etc/motd are configured"
##abf echo "1.7.1.5 Ensure permissions on /etc/issue are configured"
##abf echo "1.7.1.6 Ensure permissions on /etc/issue.net are configured"
##abf chmod 0644 /etc/motd
##abf chmod 0644 /etc/issue
##abf chmod 0644 /etc/issue.net
##abf
##abf echo "#############################################################"
##abf echo "1.8 Ensure patches, updates, and additional security software are installed"
##abf echo "Excluded from hardening.sh, added to Userdata in General AMI due to build time constraints"
##abf # yum update -y
##abf
##abf echo "#############################################################"
##abf echo "2.2.1.2 Ensure ntp is configured"
##abf echo "ntp not installed"
##abf
##abf echo "#############################################################"
##abf echo "2.2.1.3 Ensure chrony is configured"
##abf echo "Chrony not installed"
##abf
##abf echo "#############################################################"
##abf echo "2.2.15 Ensure mail transfer agent is configured for local-only mode"
##abf
##abd echo "#############################################################"
##abd echo "3.3.3 Disable ipv6"
##abd sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1 /' /etc/default/grub
##abd grub2-mkconfig -o /boot/grub2/grub.cfg
##abd
##abd echo "#############################################################"
##abd echo "3.4.2 Ensure /etc/hosts.allow is configured"
##abd echo "3.4.3 Ensure /etc/hosts.deny is configured"
##abd echo "3.4.4 Ensure permissions on /etc/hosts.allow are configured"
##abd echo "3.4.5 Ensure permissions on /etc/hosts.deny are configured"
##abd echo "Exemption: Disable host-based connection blocking as SGs do what we need"
##abd echo "ALL: ALL" > /etc/hosts.allow
##abd > /etc/hosts.deny
##abd chmod 0644 /etc/hosts.allow
##abd chmod 0644 /etc/hosts.deny
##abd
##abd echo "#############################################################"
##abd echo "3.6 Firewall Configuration"
##abd echo "3.6.1 Ensure iptables is installed"
##abd echo "3.6.2 Ensure default deny firewall policy"
##abd echo "3.6.3 Ensure loopback traffic is configured"
##abd echo "3.6.4 Ensure outbound and established connections are configured"
##abd echo "3.6.5 Ensure firewall rules exist for all open ports"
##abd echo "Configuring iptables"
##abd echo "Exemption:  SGs do what we need"
##abd
##abd echo "#############################################################"
##abd echo "4.1.1.1 Ensure audit log storage size is configured"
##abd echo "4.1.1.2 Ensure system is disabled when audit logs are full"
##abd # Note that in order to not fill disks with Audit Logs (which will be shipped to
##abd # CloudWatch), we explicitly fail to meet 4.1.1.2. Instead of keeping all logs,
##abd # we just keep the last 3 files.
##abd echo "Configuring Auditing & Logging"
##abd cat > /etc/audit/auditd.conf << AUDITD
##abd max_log_file = 100
##abd max_log_file_action = rotate
##abd num_logs = 3
##abd space_left_action = email
##abd action_mail_acct = root
##abd # OpenSCAP Rule ID auditd_data_retention_admin_space_left_action
##abd # OpenSCAP will fail as wants "single" but CIS specifies "halt"
##abd admin_space_left_action = halt
##abd AUDITD
##abd
##abd echo "#############################################################"
##abd echo "4.1.2 Ensure auditd service is enabled"
##abd echo "4.2.1.1 Ensure rsyslog Service is enabled"
##abd echo "5.1.1 Ensure cron daemon is enabled"
##abd for svc in auditd rsyslog crond; do
##abd     chkconfig $svc on
##abd done
##abd
##abd echo "#############################################################"
##abd echo "4.1.3 Ensure auditing for processes that start prior to auditd is enabled"
##abd sed -i -e '/^-a never,task/ s/$/# /' /etc/audit/audit.rules
##abd
##abd
##abd
##abd # pointless change
##abd
##abd
##abd
##abd
##abd
##abd
##abd
##abd
##abd
##abd
##abd
##abd
##abd
##abd echo "#############################################################"
##abd echo "4.1.4 Ensure events that modify date and time information are collected"
##abd echo "4.1.5 Ensure events that modify user/group information are collected"
##abd echo "4.1.6 Ensure events that modify the system's network environment are collected"
##abd echo "4.1.7 Ensure events that modify the system's Mandatory Access Controls are collected"
##abd echo "4.1.8 Ensure login and logout events are collected"
##abd echo "4.1.9 Ensure session initiation information is collected"
##abd echo "4.1.10 Ensure discretionary access control permission modification events are collected"
##abd echo "4.1.11 Ensure unsuccessful unauthorized file access attempts are collected"
##abd echo "4.1.12 Ensure use of privileged commands is collected"
##abd echo "4.1.13 Ensure successful file system mounts are collected"
##abd echo "4.1.14 Ensure file deletion events by users are collected"
##abd echo "4.1.15 Ensure changes to system administration scope (sudoers) is collected"
##abd echo "4.1.16 Ensure system administrator actions (sudolog) are collected"
##abd echo "4.1.17 Ensure kernel module loading and unloading is collected"
##abd echo "4.1.18 Ensure the audit configuration is immutable"
##abd # see https://github.com/dwp/packer-infrastructure/blob/master/amazon-ebs-builder/scripts/centos7/generic/090-harden.sh#L114
##abd cat >> /etc/audit/audit.rules << AUDITRULES
##abd # CIS 4.1.4
##abd # OpenSCAP Rule ID audit_rules_time_settimeofday
##abd # OpenSCAP Rule ID audit_rules_time_stime
##abd # Also 64bit does not have stime syscall
##abd # OpenSCAP Rule ID audit_rules_time_adjtimex
##abd -a always,exit -F arch=b64 -S adjtimex,settimeofday -F key=audit_time_rules
##abd -a always,exit -F arch=b32 -S adjtimex,settimeofday -F key=audit_time_rules
##abd -a always,exit -F arch=b32 -S stime -F key=audit_time_rules
##abd -a always,exit -F arch=b64 -S clock_settime -F key=audit_time_rules
##abd -a always,exit -F arch=b32 -S clock_settime -F key=audit_time_rules
##abd -w /etc/localtime -p wa -F key=audit_time_rules
##abd
##abd # CIS 4.1.5
##abd # Key name is changed to match OpenSCAP requirements, but functionally is the same
##abd -w /etc/group -p wa -k audit_rules_usergroup_modification
##abd -w /etc/passwd -p wa -k audit_rules_usergroup_modification
##abd -w /etc/gshadow -p wa -k audit_rules_usergroup_modification
##abd -w /etc/shadow -p wa -k audit_rules_usergroup_modification
##abd -w /etc/security/opasswd -p wa -k audit_rules_usergroup_modification
##abd
##abd # CIS 4.1.6
##abd # Key name is changed to match OpenSCAP requirements, but functionally is the same
##abd -a always,exit -F arch=b64 -S sethostname -S setdomainname -k audit_rules_networkconfig_modification
##abd -a always,exit -F arch=b32 -S sethostname -S setdomainname -k audit_rules_networkconfig_modification
##abd -w /etc/issue -p wa -k audit_rules_networkconfig_modification
##abd -w /etc/issue.net -p wa -k audit_rules_networkconfig_modification
##abd -w /etc/hosts -p wa -k audit_rules_networkconfig_modification
##abd -w /etc/sysconfig/network -p wa -k audit_rules_networkconfig_modification
##abd -w /etc/sysconfig/network-scripts/ -p wa -k audit_rules_networkconfig_modification
##abd
##abd # CIS 4.1.7
##abd -w /etc/selinux/ -p wa -k MAC-policy
##abd -w /usr/share/selinux/ -p wa -k MAC-policy
##abd
##abd # CIS 4.1.8
##abd # OpenSCAP Rule ID audit_rules_login_events
##abd # OpenSCAP added tallylog
##abd -w /var/log/tallylog -p wa -k logins
##abd -w /var/run/faillock/ -p wa -k logins
##abd -w /var/log/lastlog -p wa -k logins
##abd
##abd # CIS 4.1.9
##abd # Key name is changed to match OpenSCAP requirements, but functionally is the same
##abd -w /var/run/utmp -p wa -k session
##abd -w /var/log/wtmp -p wa -k session
##abd -w /var/log/btmp -p wa -k session
##abd
##abd # CIS 4.1.10
##abd -a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=500 -F
##abd auid!=4294967295 -k perm_mod
##abd -a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=500 -F auid!=4294967295 -k perm_mod
##abd -a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=500 -F auid!=4294967295 -k perm_mod
##abd -a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=500 -F auid!=4294967295 -k perm_mod
##abd -a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod
##abd -a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod
##abd
##abd # CIS 4.1.11
##abd # OpenSCAP Rule ID audit_rules_unsuccessful_file_modification
##abd # OpenSCAP will fail on this point as expects auid>=1000 which is less secure
##abd -a always,exit -F arch=b32 -S creat,open,openat,open_by_handle_at,truncate,ftruncate -F exit=-EACCES -F auid>=500 -F auid!=4294967295 -F key=access
##abd -a always,exit -F arch=b32 -S creat,open,openat,open_by_handle_at,truncate,ftruncate -F exit=-EPERM -F auid>=500 -F auid!=4294967295 -F key=access
##abd -a always,exit -F arch=b64 -S creat,open,openat,open_by_handle_at,truncate,ftruncate -F exit=-EACCES -F auid>=500 -F auid!=4294967295 -F key=access
##abd -a always,exit -F arch=b64 -S creat,open,openat,open_by_handle_at,truncate,ftruncate -F exit=-EPERM -F auid>=500 -F auid!=4294967295 -F key=access
##abd
##abd # CIS 4.1.13
##abd # OpenSCAP will fail on this point as expects auid>=1000 which is less secure
##abd -a always,exit -F arch=b64 -S mount -F auid>=500 -F auid!=4294967295 -k mounts
##abd -a always,exit -F arch=b32 -S mount -F auid>=500 -F auid!=4294967295 -k mounts
##abd
##abd # CIS 4.1.14
##abd # OpenSCAP Rule ID audit_rules_file_deletion_events
##abd # OpenSCAP will fail on this point as expects auid>=1000 which is less secure
##abd -a always,exit -F arch=b32 -S rmdir,unlink,unlinkat,rename -S renameat -F auid>=500 -F auid!=4294967295 -F key=delete
##abd -a always,exit -F arch=b64 -S rmdir,unlink,unlinkat,rename -S renameat -F auid>=500 -F auid!=4294967295 -F key=delete
##abd
##abd # CIS 4.1.15
##abd -w /etc/sudoers -p wa -k scope
##abd -w /etc/sudoers.d/ -p wa -k scope
##abd
##abd # CIS 4.1.16
##abd -w /var/log/sudo.log -p wa -k actions
##abd
##abd # CIS 4.1.17
##abd # OpenSCAP Rule ID audit_rules_kernel_module_loading
##abd # CIS requires /sbin/* but OpenSCAP wants /usr/sbin and they both symlink to same place
##abd -w /usr/sbin/insmod -p x -k modules
##abd -w /usr/sbin/rmmod -p x -k modules
##abd -w /usr/sbin/modprobe -p x -k modules
##abd -a always,exit -F arch=b64 -S init_module,delete_module -F key=modules
##abd
##abd # OpenSCAP remediation Rule ID audit_rules_sysadmin_actions
##abd -w /etc/sudoers -p wa -k actions
##abd -w /etc/sudoers.d/ -p wa -k actions
##abd
##abd # CIS 4.1.18
##abd -e 2
##abd AUDITRULES

##abc
##abc # OpenSCAP Rule ID audit_rules_privileged_commands
##abc echo "# CIS 4.1.12" >> /etc/audit/audit.rules
##abc for i in $(find / -xdev -type f -perm -4000 -o -type f -perm -2000 2>/dev/null); do
##abc     echo "-a always,exit -F path=${i} -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged" >> /etc/audit/audit.rules
##abc done
##abc
##abc echo "#############################################################"
##abc echo "4.2.1.2 Ensure logging is configured"
##abc # CIS recommends the following:
##abc echo "*.emerg                 :omusrmsg:*" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
##abc echo "mail.*                  -/var/log/mail" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
##abc echo "mail.info               -/var/log/mail.info" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
##abc echo "mail.warning            -/var/log/mail.warn" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
##abc echo "mail.err                 /var/log/mail.err" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
##abc echo "news.crit               -/var/log/news/news.crit" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
##abc echo "news.err                -/var/log/news/news.err" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
##abc echo "news.notice             -/var/log/news/news.notice" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
##abc echo "*.=warning;*.=err       -/var/log/warn" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
##abc echo "*.crit                   /var/log/warn" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
##abc echo "*.*;mail.none;news.none -/var/log/messages" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
##abc echo "local0,local1.*         -/var/log/localmessages" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
##abc echo "local2,local3.*         -/var/log/localmessages" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
##abc echo "local4,local5.*         -/var/log/localmessages" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
##abc echo "local6,local7.*         -/var/log/localmessages" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
##abc
##abc echo "#############################################################"
##abc echo "4.2.1.3 Ensure rsyslog default file permissions configured"
##abc sed -i -e 's/^$FileCreateMode.*/$FileCreateMode 0640/' /etc/rsyslog.conf
##abc sed -i -e 's/^$FileCreateMode.*/$FileCreateMode 0640/' /etc/rsyslog.d/*.conf
##abc
##abc echo "#############################################################"
##abc echo "4.2.1.4 Ensure rsyslog is configured to send logs to a remote host"
##abc echo "Exemption: all AWS instances *must* send logs to CloudWatch"
##abc
##abc echo "#############################################################"
##abc echo "4.2.1.5 Ensure remote rsyslog messages are only accepted on designated log hosts."
##abc sed -i -e '/^$ModLoad imtcp/d' -e '/^$InputTCPServerRun 514/d' /etc/rsyslog.d/*.conf
##abc sed -i -e '/^$ModLoad imtcp/d' -e '/^$InputTCPServerRun 514/d' /etc/rsyslog.conf
##abc
##abc echo "#############################################################"
##abc echo "4.2.2.1 Ensure syslog-ng service is enabled"
##abc echo "4.2.2.2 Ensure logging is configured"
##abc echo "4.2.2.3 Ensure syslog-ng default file permissions configured"
##abc echo "4.2.2.4 Ensure syslog-ng is configured to send logs to a remote log host"
##abc echo "4.2.2.5 Ensure remote syslog-ng messages are only accepted on designated log hosts"
##abc echo "Exemption: We install / configure rsyslog rather than syslog-ng"
##abc
##abc echo "#############################################################"
##abc echo "4.2.4 Ensure permissions on all logfiles are configured"
##abc find /var/log -type f -exec chmod 0640 {} \;
##abc
##abc echo "#############################################################"
##abc echo "4.3 Ensure logrotate is configured"
##abc echo "Exemption: userdata is used to configure log rotation via logrotate"
##abc
##abc echo "#############################################################"
##abc echo "5.1.2 Ensure permissions on /etc/crontab are configured"
##abc echo "5.1.3 Ensure permissions on /etc/cron.hourly are configured"
##abc echo "5.1.4 Ensure permissions on /etc/cron.daily are configured"
##abc echo "5.1.5 Ensure permissions on /etc/cron.weekly are configured"
##abc echo "5.1.6 Ensure permissions on /etc/cron.monthly are configured"
##abc chmod 0600 /etc/crontab
##abc chmod 0600 /etc/cron.hourly
##abc chmod 0600 /etc/cron.daily
##abc chmod 0600 /etc/cron.weekly
##abc chmod 0600 /etc/cron.monthly
##abc
##abc echo "#############################################################"
##abc echo "5.1.7 Ensure permissions on /etc/cron.d are configured"
##abc chmod 0700 /etc/cron.d
##abc
##abc echo "#############################################################"
##abc echo "5.1.8 Ensure at/cron is restricted to authorized users"
##abc rm -f /etc/cron.deny /etc/at.deny
##abc touch /etc/cron.allow /etc/at.allow
##abc chmod 0600 /etc/cron.allow /etc/at.allow
##abc chown root:root /etc/cron.allow /etc/at.allow
##abc
##abc echo "#############################################################"
##abc echo "5.2.1 Ensure permissions on /etc/ssh/sshd_config are configured"
##abc chown root:root /etc/ssh/sshd_config
##abc chmod 0600 /etc/ssh/sshd_config
##abc
##abc echo "#############################################################"
##abc echo "5.2.2 Ensure SSH Protocol is set to 2"
##abc echo "5.2.3 Ensure SSH LogLevel is set to INFO"
##abc echo "5.2.4 Ensure SSH X11 forwarding is disabled"
##abc echo "5.2.5 Ensure SSH MaxAuthTries is set to 4 or less"
##abc echo "5.2.6 Ensure SSH IgnoreRhosts is enabled"
##abc echo "5.2.7 Ensure SSH HostbasedAuthentication is disabled"
##abc echo "5.2.8 Ensure SSH root login is disabled"
##abc echo "5.2.9 Ensure SSH PermitEmptyPasswords is disabled"
##abc echo "5.2.10 Ensure SSH PermitUserEnvironment is disabled"
##abc echo "5.2.11 Ensure only approved MAC algorithms are used"
##abc echo "5.2.12 Ensure SSH Idle Timeout Interval is configured"
##abc echo "5.2.13 Ensure SSH LoginGraceTime is set to one minute or less"
##abc echo "5.2.14 Ensure SSH access is limited"
##abc echo "5.2.15 Ensure SSH warning banner is configured"
##abc echo "Configuring SSH"
##abc echo Create sshusers and no-ssh-access groups
##abc groupadd sshusers || true
##abc groupadd no-ssh-access || true
##abc
##abc echo add ec2-user to sshusers group to allow access
##abc usermod -a -G sshusers ec2-user
##abc
##abc echo apply hardened SSHD config
##abc cat > /etc/ssh/sshd_config << SSHCONFIG
##abc Port 22
##abc ListenAddress 0.0.0.0
##abc Protocol 2
##abc HostKey /etc/ssh/ssh_host_rsa_key
##abc HostKey /etc/ssh/ssh_host_dsa_key
##abc HostKey /etc/ssh/ssh_host_ecdsa_key
##abc HostKey /etc/ssh/ssh_host_ed25519_key
##abc UsePrivilegeSeparation yes
##abc KeyRegenerationInterval 3600
##abc ServerKeyBits 2048
##abc SyslogFacility AUTH
##abc LogLevel INFO
##abc ClientAliveInterval 300
##abc ClientAliveCountMax 0
##abc LoginGraceTime 60
##abc PermitRootLogin no
##abc StrictModes yes
##abc MaxAuthTries 4
##abc MaxSessions 10
##abc RSAAuthentication yes
##abc PubkeyAuthentication yes
##abc AuthorizedKeysCommand /usr/bin/sss_ssh_authorizedkeys
##abc AuthorizedKeysCommandUser nobody
##abc IgnoreRhosts yes
##abc RhostsRSAAuthentication no
##abc HostbasedAuthentication no
##abc PermitEmptyPasswords no
##abc ChallengeResponseAuthentication no
##abc PasswordAuthentication no
##abc KerberosAuthentication no
##abc GSSAPIAuthentication yes
##abc GSSAPICleanupCredentials yes
##abc X11Forwarding no
##abc X11DisplayOffset 10
##abc PrintMotd no
##abc PrintLastLog yes
##abc TCPKeepAlive yes
##abc Banner /etc/issue
##abc AcceptEnv LANG LC_* XMODIFIERS
##abc Subsystem sftp    /usr/libexec/openssh/sftp-server
##abc UsePAM yes
##abc UseDNS no
##abc DenyUsers no-ssh-access
##abc AllowGroups sshusers
##abc # OpenSCAP Rule ID sshd_use_approved_ciphers
##abc # OpenSCAP will fail with this cipher set, but ours is more strict
##abc Ciphers aes256-ctr,aes192-ctr,aes128-ctr
##abc MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com
##abc PermitUserEnvironment no
##abc SSHCONFIG
##abc
##abc echo "#############################################################"
##abc echo "5.3.1 Ensure password creation requirements are configured"
##abc echo "5.3.2 Ensure lockout for failed password attempts is configured"
##abc echo "5.3.3 Ensure password reuse is limited"
##abc echo "5.3.4 Ensure password hashing algorithm is SHA-512"
##abc # See https://git.ucd.gpn.gov.uk/dip/aws-common-infrastructure/wiki/Access-Management-Policy#regular-users
##abc sed -i 's/^# minlen.*$/minlen = 24/' /etc/security/pwquality.conf
##abc sed -i 's/^# difok.*$/difok = 1/' /etc/security/pwquality.conf
##abc # AL1 defaults are generally better than CIS requirements
##abc # 5.3.1 - Check /etc/pam.d/password-auth and /etc/pam.d/system-auth contain:
##abc # password requisite pam_pwquality.so try_first_pass retry=3
##abc # 5.3.2 - Ensure lockout for failed password attempts is configured
##abc # auth required pam_faillock.so preauth audit silent deny=10 unlock_time=900
##abc # auth [success=1 default=bad] pam_unix.so
##abc # auth [default=die] pam_faillock.so authfail audit deny=10 unlock_time=900
##abc # auth sufficient pam_faillock.so authsucc audit deny=10 unlock_time=900
##abc # OpenSCAP Rule ID accounts_passwords_pam_faillock_deny will fail (we deny at 10 in line with our policy)
##abc # OpenSCAP Rule ID removed nullok entries
##abc cat > /etc/pam.d/system-auth << PAMSYSCONFIG
##abc auth        required                   pam_env.so
##abc auth        required                   pam_faildelay.so delay=2000000
##abc auth        required                   pam_faillock.so preauth audit silent deny=10 unlock_time=900
##abc auth        sufficient                 pam_unix.so try_first_pass
##abc auth        sufficient                 pam_faillock.so authsucc audit deny=10 unlock_time=900
##abc auth        requisite                  pam_succeed_if.so uid >= 500 quiet_success
##abc auth        required                   pam_deny.so
##abc auth        [success=1 default=bad]    pam_unix.so
##abc auth        [default=die]              pam_faillock.so authfail audit deny=10 unlock_time=900
##abc
##abc account     required                   pam_faillock.so
##abc account     required                   pam_unix.so
##abc account     sufficient                 pam_localuser.so
##abc account     sufficient                 pam_succeed_if.so uid < 500 quiet
##abc account     required                   pam_permit.so
##abc
##abc password    requisite                  pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
##abc password    sufficient                 pam_unix.so sha512 shadow try_first_pass use_authtok remember=5
##abc password    required                   pam_deny.so
##abc
##abc session     optional                   pam_keyinit.so revoke
##abc session     required                   pam_limits.so
##abc -session    optional                   pam_systemd.so
##abc session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
##abc session     required                   pam_unix.so
##abc PAMSYSCONFIG
##abc
##abc echo "#############################################################"
##abc echo "5.4.1.1 Ensure password expiration is 365 days or less"
##abc echo "Whilst no users will be logging on to this system, our policy is 90 days for regular users and 365 for machine users"
##abc # Refs: https://git.ucd.gpn.gov.uk/dip/aws-common-infrastructure/wiki/Access-Management-Policy#regular-users
##abc #       https://git.ucd.gpn.gov.uk/dip/aws-common-infrastructure/wiki/Access-Management-Policy#machine-accounts
##abc sed -i 's/^PASS_MAX_DAYS.*$/PASS_MAX_DAYS 90/' /etc/login.defs
##abc
##abc echo "#############################################################"
##abc echo "5.4.1.2 Ensure minimum days between password changes is 7 or more"
##abc sed -i 's/^PASS_MIN_DAYS.*$/PASS_MIN_DAYS 7/' /etc/login.defs
##abc
##abc echo "#############################################################"
##abc echo "5.4.1.3 Ensure password expiration warning days is 7 or more"
##abc     sed -i 's/^PASS_WARN_AGE.*$/PASS_WARN_AGE 7/' /etc/login.defs
##abc
##abc echo "#############################################################"
##abc echo "5.4.1.4 Ensure inactive password lock is 30 days or less"
##abc useradd -D -f 30
##abc
##abc echo "#############################################################"
##abc echo "5.4.1.5 Ensure all users last password change date is in the past"
##abc echo "Exemption: we have no users that we configure with passwords"
##abc
##abc echo "#############################################################"
##abc echo "5.4.2 Ensure system accounts are non-login"
##abc echo "Exemption: No users in AL1 have this, CWA adds it later but we have dealt with this upstream"
##abc
##abc echo "#############################################################"
##abc echo "5.4.3 Ensure default group for the root account is GID 0"
##abc usermod -g 0 root
##abc
##abc echo "#############################################################"
##abc echo "5.4.4 Ensure default user umask is 027 or more restrictive"
##abc sed -i 's/^.*umask 0.*$/umask 027/' /etc/bashrc
##abc sed -i 's/^.*umask 0.*$/umask 027/' /etc/profile
##abc sed -i 's/^.*umask 0.*$/umask 027/' /etc/profile.d/*.sh
##abc
##abc echo "#############################################################"
##abc echo "5.4.5 Ensure default user shell timeout is 900 seconds or less"
##abc echo 'TMOUT=600' >> /etc/bashrc
##abc echo 'TMOUT=600' >> /etc/profile
##abc
##abc echo "#############################################################"
##abc echo "5.5 Ensure access to the su command is restricted"
##abc sed -i '/#auth.*required.*pam_wheel.so/s/^# *//' /etc/pam.d/su
##abc
##abc echo "#############################################################"
##abc echo "6.1.1 Audit system file permissions"
##abc echo "Exemption: We are not auditing all system files, unscored"
##abc
##abc echo "#############################################################"
##abc echo "6.1.2 Ensure permissions on /etc/passwd are configured"
##abc chown root:root /etc/passwd
##abc chmod 644 /etc/passwd
##abc
##abc echo "#############################################################"
##abc echo "6.1.3 Ensure permissions on /etc/shadow are configured"
##abc chown root:root /etc/shadow
##abc chmod 000 /etc/shadow
##abc
##abc echo "#############################################################"
##abc echo "6.1.4 Ensure permissions on /etc/group are configured"
##abc chown root:root /etc/group
##abc chmod 644 /etc/group
##abc
##abc echo "#############################################################"
##abc echo "6.1.5 Ensure permissions on /etc/gshadow are configured"
##abc chown root:root /etc/gshadow
##abc chmod 000 /etc/gshadow
##abc
##abc echo "#############################################################"
##abc echo "6.1.6 Ensure permissions on /etc/passwd-are configured"
##abc chown root:root /etc/passwd-
##abc chmod u-x,go-wx /etc/passwd-
##abc
##abc echo "#############################################################"
##abc echo "6.1.7 Ensure permissions on /etc/shadow-are configured"
##abc chown root:root /etc/shadow-
##abc chmod 000 /etc/shadow-
##abc
##abc echo "#############################################################"
##abc echo "6.1.8 Ensure permissions on /etc/group-are configured"
##abc chown root:root /etc/group-
##abc chmod u-x,go-wx /etc/group-
##abc
##abc echo "#############################################################"
##abc echo "6.1.9 Ensure permissions on /etc/gshadow-are configured "
##abc chown root:root /etc/gshadow-
##abc chmod 000 /etc/gshadow-
##abc
##abc echo "#############################################################"
##abc echo "6.1.10 Ensure no world writable files exist"
##abc echo "Expect: no output"
##abc # OpenSCAP Rule ID file_permissions_unauthorized_world_writable will fail (have verified there is no output for command)
##abc df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type f -perm -0002
##abc
##abc echo "#############################################################"
##abc echo "6.1.11 Ensure no unowned files or directories exist"
##abc echo "Expect: no output"
##abc df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nouser
##abc
##abc echo "#############################################################"
##abc echo "6.1.12 Ensure no ungrouped files or directories exist"
##abc echo "Expect: no output"
##abc df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nogroup
##abc
##abc echo "#############################################################"
##abc echo "6.1.13 Audit SUID executables"
##abc # OpenSCAP Rule ID file_permissions_unauthorized_suid
##abc echo "Exemption: we are not auditing all system files, unscored"
##abc
##abc echo "#############################################################"
##abc echo "6.1.14 Audit SGID executables"
##abc # OpenSCAP Rule ID file_permissions_unauthorized_sgid
##abc echo "Exemption: we are not auditing all system files, unscored"
##abc
##abc echo "#############################################################"
##abc echo "6.2.1 Ensure password fields are not empty"
##abc echo "Expect: no output"
##abc cat /etc/shadow | awk -F: '($2 == "" ) { print $1 " does not have a password "}'
##abc
##abc echo "#############################################################"
##abc echo "6.2.2 Ensure no legacy '+' entries exist in /etc/passwd"
##abc echo "Expect: no output"
##abc grep '^\+:' /etc/passwd || true
##abc
##abc echo "#############################################################"
##abc echo "6.2.3 Ensure no legacy '+' entries exist in /etc/shadow"
##abc echo "Expect: no output"
##abc grep '^\+:' /etc/shadow || true
##abc
##abc echo "#############################################################"
##abc echo "6.2.4 Ensure no legacy '+' entries exist in /etc/group"
##abc echo "Expect: no output"
##abc grep '^\+:' /etc/group || true
##abc
##abc echo "#############################################################"
##abc echo "6.2.5 Ensure root is the only UID 0 account"
##abc echo "Expect: root"
##abc cat /etc/passwd | awk -F: '($3 == 0) { print $1 }'
##abc
##abc echo "#############################################################"
##abc echo "6.2.6 Ensure root PATH Integrity"
##abc echo "Expect: no '.' or other writeable directory in PATH"
##abc echo $PATH
##abc
##abc echo "#############################################################"
##abc echo "6.2.7 Ensure all users' home directories exist"
##abc echo "Expect: all users to have home folders"
##abc cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }'
##abc
##abc echo "#############################################################"
##abc echo "6.2.8 Ensure users' home directories permissions are 750 or more restrictive"
##abc echo "Expect: no output"
##abc cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
##abc   if [ ! -d "$dir" ]; then
##abc     echo "The home directory ($dir) of user $user does not exist."
##abc   else
##abc     dirperm=`ls -ld $dir | cut -f1 -d" "`
##abc     if [ `echo $dirperm | cut -c6` != "-" ]; then
##abc       echo "Group Write permission set on the home directory ($dir) of user $user"
##abc     fi
##abc     if [ `echo $dirperm | cut -c8` != "-" ]; then
##abc       echo "Other Read permission set on the home directory ($dir) of user $user"
##abc     fi
##abc     if [ `echo $dirperm | cut -c9` != "-" ]; then
##abc       echo "Other Write permission set on the home directory ($dir) of user $user"
##abc     fi
##abc     if [ `echo $dirperm | cut -c10` != "-" ]; then
##abc       echo "Other Execute permission set on the home directory ($dir) of user $user"
##abc     fi
##abc   fi
##abc done
##abc
##abc echo "#############################################################"
##abc echo "6.2.9 Ensure users own their home directories"
##abc echo "Expect: no output"
##abc cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
##abc   if [ ! -d "$dir" ]; then
##abc     echo "The home directory ($dir) of user $user does not exist."
##abc   else
##abc     owner=$(stat -L -c "%U" "$dir")
##abc     if [ "$owner" != "$user" ]; then
##abc       echo "The home directory ($dir) of user $user is owned by $owner."
##abc     fi
##abc   fi
##abc done
##abc
##abc echo "#############################################################"
##abc echo "6.2.10 Ensure users' dot files are not group or world writable"
##abc echo "Expect: no output"
##abc cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
##abc   if [ ! -d "$dir" ]; then
##abc     echo "The home directory ($dir) of user $user does not exist."
##abc   else
##abc     for file in $dir/.[A-Za-z0-9]*; do
##abc       if [ ! -h "$file" -a -f "$file" ]; then
##abc         fileperm=`ls -ld $file | cut -f1 -d" "`
##abc         if [ `echo $fileperm | cut -c6` != "-" ]; then
##abc           echo "Group Write permission set on file $file"
##abc         fi
##abc         if [ `echo $fileperm | cut -c9`  != "-" ]; then
##abc           echo "Other Write permission set on file $file"
##abc         fi
##abc       fi
##abc     done
##abc   fi
##abc done
##abc
##abc echo "#############################################################"
##abc echo "6.2.11 Ensure no users have .forward files"
##abc echo "Expect: no output"
##abc cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
##abc   if [ ! -d "$dir" ]; then
##abc     echo "The home directory ($dir) of user $user does not exist."
##abc   else
##abc     if [ ! -h "$dir/.forward" -a -f "$dir/.forward" ]; then
##abc       echo ".forward file $dir/.forward exists"
##abc     fi
##abc   fi
##abc done
##abc
##abc echo "#############################################################"
##abc echo "6.2.12 Ensure no users have .netrc files"
##abc echo "Expect: no output"
##abc cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
##abc   if [ ! -d "$dir" ]; then
##abc     echo "The home directory ($dir) of user $user does not exist."
##abc   else
##abc     if [ ! -h "$dir/.netrc" -a -f "$dir/.netrc" ]; then
##abc       echo ".netrc file $dir/.netrc exists"
##abc     fi
##abc   fi
##abc done
##abc
##abc echo "#############################################################"
##abc echo "6.2.13 Ensure users' .netrc Files are not group or world accessible"
##abc echo "Expect: no output"
##abc cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
##abc   if [ ! -d "$dir" ]; then
##abc     echo "The home directory ($dir) of user $user does not exist."
##abc   else
##abc     for file in $dir/.netrc; do
##abc       if [ ! -h "$file" -a -f "$file" ]; then
##abc         fileperm=`ls -ld $file | cut -f1 -d" "`
##abc         if [ `echo $fileperm | cut -c5`  != "-" ]; then
##abc           echo "Group Read set on $file"
##abc         fi
##abc         if [ `echo $fileperm | cut -c6`  != "-" ]; then
##abc           echo "Group Write set on $file"
##abc         fi
##abc         if [ `echo $fileperm | cut -c7`  != "-" ]; then
##abc           echo "Group Execute set on $file"
##abc         fi
##abc         if [ `echo $fileperm | cut -c8`  != "-" ]; then
##abc           echo "Other Read set on $file"
##abc         fi
##abc         if [ `echo $fileperm | cut -c9`  != "-" ]; then
##abc           echo "Other Write set on $file"
##abc         fi
##abc         if [ `echo $fileperm | cut -c10`  != "-" ]; then
##abc           echo "Other Execute set on $file"
##abc         fi
##abc       fi
##abc     done
##abc   fi
##abc done
##abc
##abc echo "#############################################################"
##abc echo "6.2.14 Ensure no users have .rhosts files"
##abc echo "Expect: no output"
##abc cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
##abc   if [ ! -d "$dir" ]; then
##abc     echo "The home directory ($dir) of user $user does not exist."
##abc   else
##abc     for file in $dir/.rhosts; do
##abc       if [ ! -h "$file" -a -f "$file" ]; then
##abc         echo ".rhosts file in $dir"
##abc       fi
##abc     done
##abc   fi
##abc done
##abc
##abc echo "#############################################################"
##abc echo "6.2.15 Ensure all groups in /etc/passwd exist in /etc/group"
##abc echo "Expect: no output"
##abc for i in $(cut -s -d: -f4 /etc/passwd | sort -u ); do
##abc   grep -q -P "^.*?:[^:]*:$i:" /etc/group
##abc   if [ $? -ne 0 ]; then
##abc    echo "Group $i is referenced by /etc/passwd but does not exist in /etc/group"
##abc   fi
##abc done
##abc
##abc echo "#############################################################"
##abc echo "6.2.16 Ensure no duplicate UIDs exist"
##abc echo "Expect: no output"
##abc cat /etc/passwd | cut -f3 -d":" | sort -n | uniq -c | while read x ; do
##abc   [ -z "${x}" ] && break
##abc   set - $x
##abc   if [ $1 -gt 1 ]; then
##abc     users= `awk -F: '($3 == n) { print $1 }' n=$2 /etc/passwd | xargs`
##abc     echo "Duplicate UID ($2): ${users}"
##abc   fi
##abc done
##abc
##abc echo "#############################################################"
##abc echo "6.2.17 Ensure no duplicate GIDs exist"
##abc cat /etc/group | cut -f3 -d":" | sort -n | uniq -c | while read x ; do
##abc   [ -z "${x}" ] && break
##abc   set - $x
##abc   if [ $1 -gt 1 ]; then
##abc     groups= `awk -F: '($3 == n) { print $1 }' n=$2 /etc/group | xargs`
##abc     echo "Duplicate GID ($2): ${groups}"
##abc   fi
##abc done
##abc
##abc echo "#############################################################"
##abc echo "6.2.18 Ensure no duplicate user names exist"
##abc echo "Expect: no output"
##abc cat /etc/passwd | cut -f1 -d":" | sort -n | uniq -c | while read x ; do
##abc   [ -z "${x}" ] && break
##abc   set - $x
##abc   if [ $1 -gt 1 ]; then
##abc     uids= `awk -F: '($1 == n) { print $3 }' n=$2 /etc/passwd | xargs`
##abc     echo "Duplicate User Name ($2): ${uids}"
##abc   fi
##abc done
##abc
##abc echo "#############################################################"
##abc echo "6.2.19 Ensure no duplicate group names exist"
##abc echo "Expect: no output"
##abc cat /etc/group | cut -f1 -d":" | sort -n | uniq -c | while read x ; do
##abc   [ -z "${x}" ] && break
##abc   set - $x
##abc   if [ $1 -gt 1 ]; then
##abc     gids= `gawk -F: '($1 == n) { print $3 }' n=$2 /etc/group | xargs`
##abc     echo "Duplicate Group Name ($2): ${gids}"
##abc   fi
##abc done
##abc
##abc
##abc # OpenSCAP fix for Rule ID no_direct_root_logins
##abc > /etc/securetty
##abc # This should empty this file, however ttyS0 will always be added back in as it is a
##abc # built-in that's ensuring there can be a root logon to console, which cannot happen in AWS
##abc
##abc # OpenSCAP Rule ID mount_option_dev_shm_noexec will fail (we exempt partitioning)
##abc # OpenSCAP Rule ID mount_option_dev_shm_nosuid will fail (we exempt partitioning)
##abc # OpenSCAP Rule ID mount_option_var_tmp_bind will fail (we exempt partitioning)
##abc # OpenSCAP Rule ID mount_option_dev_shm_node will fail (we exempt partitioning)
##abc # OpenSCAP Rule ID rsyslog_remote_loghost will fail (we offload logs to CloudWatch instead)
##abc # OpenSCAP Rule ID selinux_confinement_of_daemons will fail (we have verified the output the query generates)
##abc # OpenSCAP Rule ID grub_legacy_password will fail (will cause Instance not to boot)
##abc # OpenSCAP Rule ID rpm_verify_permissions will fail (CIS explicitly sets the perms on these files)
##abc # OpenSCAP Rule ID rpm_verify_hashes will fail (we have verified the output the query generates)
##abc # OpenSCAP Rule ID mount_option_tmp_nodev, mount_option_tmp_noexec, mount_option_tmp_nosuid, mount_option_var_tmp_bind (exemption as we don't have sep partition for /tmp)
##abc # OpenSCAP Rule ID rsyslog_files_permissions will fail (cloud-init appears to be setting back to 644)
##abc # OpenSCAP Rule ID service_ip6tables_enabled will fail (we are not using ipv6)
##abc # OpenSCAP Rule ID sysctl_net_ipv6_conf_default_accept_ra will fail (we are not using ipv6)
##abc # OpenSCAP Rule ID sysctl_net_ipv6_conf_default_accept_redirects will fail (we are not using ipv6)
##abc
##abc
##abc # OpenSCAP Rule ID ensure_logrotate_activated
##abc # CIS 4.3 - Ensure logrotate is configured
##abc sed -i 's/^weekly/daily/' /etc/logrotate.conf
##abc
##abc
##abc
##abc # OpenSCAP Rule ID service_ip6tables_enabled
##abc #service ip6tables stop
##abc #chkconfig ip6tables off
##abc
##abc # OpenSCAP Rule ID umask_for_daemons
##abc sed -i 's/^umask 022/umask 027/' /etc/init.d/functions
##abc
##abc sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/sysconfig/selinux
##abc
