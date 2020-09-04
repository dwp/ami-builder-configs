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
> /etc/modprobe.d/CIS.conf
for fs in cramfs freevxfs jffs2 hfs hfsplus squashfs udf vfat \
    dccp sctp rds tipc; do
    echo "install $fs /bin/true" >> /etc/modprobe.d/CIS.conf
done

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

echo "#############################################################"
echo "1.1.19 Disable Automounting"
echo "2.1.1 Ensure chargen services are not enabled"
echo "2.1.2 Ensure daytime services are not enabled"
echo "2.1.3 Ensure discard services are not enabled"
echo "2.1.4 Ensure echo services are not enabled"
echo "2.1.5 Ensure time services are not enabled"
echo "2.1.6 Ensure rsh server is not enabled"
echo "2.1.7 Ensure talk server is not enabled"
echo "2.1.8 Ensure telnet server is not enabled"
echo "2.1.9 Ensure tftp server is not enabled"
echo "2.1.10 Ensure rsync service is not enabled"
echo "2.1.11 Ensure xinetd is not enabled"
echo "2.2.3 Ensure Avahi Server is not enabled"
echo "2.2.4 Ensure CUPS is not enabled"
echo "2.2.5 Ensure DHCP Server is not enabled"
echo "2.2.6 Ensure LDAP server is not enabled"
echo "2.2.7 Ensure NFS and RPC are not enabled"
echo "2.2.8 Ensure DNS Server is not enabled"
echo "2.2.9 Ensure FTP Server is not enabled"
echo "2.2.10 Ensure HTTP server is not enabled"
echo "2.2.11 Ensure IMAP and POP3 server is not enabled"
echo "2.2.12 Ensure Samba is not enabled"
echo "2.2.13 Ensure HTTP Proxy Server is not enabled"
echo "2.2.14 Ensure SNMP Server is not enabled"
echo "2.2.15 Ensure mail transfer agent is configured for local-only mode"
echo "2.2.16 Ensure NIS Server is not enabled"
echo "Disabling unnecessary services"
echo "Only installed service is rpcbind"
for svc in rpcbind; do
    chkconfig $svc off
done;

echo "#############################################################"
echo "1.2 Configure Software Updates"
echo "1.2.1 Ensure package manager repositories are configured"
echo "1.2.2 Ensure GPG keys are configured"
echo "1.2.3 Ensure gpgcheck is globally activated"
echo "Exemption: in-life instances require no access to package repositories; they'll be rebuilt from refreshed AMIs"

echo "#############################################################"
echo "1.3.1 Ensure AIDE is installed"
echo "1.6.2 Ensure SELinux is installed"
echo "2.2.1.1 Ensure time synchronization is in use"
echo "3.4.1 Ensure TCP Wrappers is installed"
echo "3.6.1 Ensure iptables is installed"
echo "4.2.3 Ensure rsyslog or syslog-ng is installed"
echo "Installing required packages"
yum install -y \
  aide \
  libselinux \
  tcp_wrappers \
  iptables \
  rsyslog

echo "#############################################################"
echo "1.3.1 Ensure AIDE is installed"
aide --init
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

echo "#############################################################"
echo "1.3.2 Ensure filesystem integrity is regularly checked"
echo "0 5 * * * root /usr/sbin/aide --check" > /etc/cron.d/99-CIS

echo "#############################################################"
echo "1.4 Secure Boot Settings"
echo "1.4.1 Ensure permissions on bootloader config are configured"

echo "#############################################################"
echo "1.4.2 Ensure authentication required for single user mode"
echo "Exemption: AWS instances do not allow access to the bootloader or console when the instance is started."

echo "#############################################################"
echo "1.4.3 Ensure interactive boot is not enabled"
echo "PROMPT=NO" >> /etc/sysconfig/init
# OpenSCAP Rule ID require_singleuser_auth
echo "SINGLE=/sbin/sulogin" >> /etc/sysconfig/init

echo "#############################################################"
echo "1.5 Additional process hardening"
echo "1.5.1 Ensure core dumps are restricted"
echo "* hard core 0" > /etc/security/limits.d/CIS.conf

echo "#############################################################"
echo "1.5.1 Ensure core dumps are restricted"
echo "1.5.3 Ensure address space layout randomization (ASLR) is enabled"
echo "3.1.1 Ensure IP forwarding is disabled"
echo "3.1.2 Ensure packet redirect sending is disabled"
echo "3.2.1 Ensure source routed packets are not accepted"
echo "3.2.2 Ensure ICMP redirects are not accepted"
echo "3.2.3 Ensure secure ICMP redirects are not accepted"
echo "3.2.4 Ensure suspicious packets are logged"
echo "3.2.5 Ensure broadcast ICMP requests are ignored"
echo "3.2.6 Ensure bogus ICMP responses are ignored"
echo "3.2.7 Ensure Reverse Path Filtering is enabled"
echo "3.2.8 Ensure TCP SYN Cookies is enabled"
echo "3.3.1 Ensure IPv6 router advertisements are not accepted"
echo "3.3.2 Ensure IPv6 redirects are not accepted"
echo "Tweaking sysctl knobs"

# OpenSCAP sysctl_net_ipv6_conf_default_accept_ra, sysctl_net_ipv6_conf_default_accept_redirects
cat >> /etc/sysctl.conf << SYSCTL
fs.suid_dumpable = 0
kernel.randomize_va_space = 2
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
SYSCTL

echo "#############################################################"
echo "1.5.2 Ensure XD/NX support is enabled"
echo "Expect: active"
dmesg | grep NX

echo "#############################################################"
echo "1.5.4 Ensure prelink is disabled"
echo "1.6.1.4 Ensure SETroubleshoot is not installed"
echo "1.6.1.5 Ensure the MCS Translation Service (mcstrans) is not installed"
echo "2.2.1.1 Ensure time synchronization is in use"
echo "2.2.2 Ensure X Window System is not installed"
echo "2.3.1 Ensure NIS Client is not installed"
echo "2.3.2 Ensure rsh client is not installed"
echo "2.3.3 Ensure talk client is not installed"
echo "2.3.4 Ensure telnet client is not installed"
echo "2.3.5 Ensure LDAP client is not installed"
echo "Removing unneccessary packages"
yum remove -y  \
    prelink \
    setroubleshoot \
    mcstrans \
    xorg-x11* \
    ypbind \
    rsh \
    talk \
    telnet \
    openldap-clients --remove-leaves

echo "#############################################################"
echo "1.6.1.1 - Ensure SELinux is not disabled in bootloader configuration"
echo "Expect: no setting with selinux=0 or enforcing=0"

echo "#############################################################"
echo "1.6.1.2 Ensure the SELinux state is enforcing"
echo "1.6.1.3 Ensure SELinux policy is configured"
echo "Configuring SELinux"
# Install pre-requisites
yum install -y \
    selinux-policy \
    selinux-policy-targeted \
    policycoreutils-python

#create config file
cat > /etc/selinux/config << EOF
SELINUX=enforcing
SELINUXTYPE=targeted
EOF

# Create AutoRelabel
touch /.autorelabel

echo "#############################################################"
echo "1.6.1.6 - Ensure no unconfined daemons exist"
echo "Expect: no output"
ps -eZ | egrep "initrc" | egrep -vw "tr|ps|egrep|bash|awk" | tr ':' ' ' | awk '{ print $NF }'


echo "#############################################################"
echo "1.7 Warning Banners"
echo "1.7.1 Command Line Warning Banners"
echo "1.7.1.1 Ensure message of the day is configured properly"
# Ensure /etc/motd contains nothing; we want to display a warning *before* login
# in compliance with DWP norms (see 1.7.1.2 below)
> /etc/motd

# OpenSCAP Rule ID banner_etc_issue will fail (requires a DOD banner)
echo "#############################################################"
echo "1.7.1.2 Ensure local login warning banner is configured properly"
cat > /etc/issue << BANNER
/------------------------------------------------------------------------------\
|                              ***** WARNING *****                             |
|                                                                              |
| UNAUTHORISED ACCESS TO THIS DEVICE IS PROHIBITED                             |
|                                                                              |
| You must have explicit, authorised permission to access or configure this    |
| device. Unauthorised use of this device is a criminal offence under the      |
| Computer Misuse Act 1990. Unauthorized attempts and actions to access or use |
| this system may result in civil and/or criminal penalties.                   |
|                                                                              |
| All actions performed on this system must be in accordance with the          |
| Department's Acceptable Use Policy and Security Operating Procedures         |
| (SyOps). You must ensure you have read and understand these before           |
| attempting to log  |on to this system. Use of this system constitutes        |
| acceptance by you of the provisions of the SyOPs with immediate effect.      |
|                                                                              |
| All activities performed on this device are logged and monitored.            |
|                                                                              |
| If you do not understand any part of this message then please ask your line  |
| manager for further guidance before proceeding.                              |
\------------------------------------------------------------------------------/
BANNER

echo "#############################################################"
echo "1.7.1.3 Ensure remote login warning banner is configured properly"
# We don't intend to allow remote logins, but this meets CIS compliance and
# ensures compliance with DWP norms if we do decide to enable remote logins
cp /etc/issue /etc/issue.net

echo "#############################################################"
echo "1.7.1.4 Ensure permissions on /etc/motd are configured"
echo "1.7.1.5 Ensure permissions on /etc/issue are configured"
echo "1.7.1.6 Ensure permissions on /etc/issue.net are configured"
chmod 0644 /etc/motd
chmod 0644 /etc/issue
chmod 0644 /etc/issue.net

echo "#############################################################"
echo "1.8 Ensure patches, updates, and additional security software are installed"
echo "Excluded from hardening.sh, added to Userdata in General AMI due to build time constraints"
# yum update -y

echo "#############################################################"
echo "2.2.1.2 Ensure ntp is configured"
echo "ntp not installed"

echo "#############################################################"
echo "2.2.1.3 Ensure chrony is configured"
echo "Chrony not installed"

echo "#############################################################"
echo "2.2.15 Ensure mail transfer agent is configured for local-only mode"

echo "#############################################################"
echo "3.3.3 Disable ipv6"
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1 /' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

echo "#############################################################"
echo "3.4.2 Ensure /etc/hosts.allow is configured"
echo "3.4.3 Ensure /etc/hosts.deny is configured"
echo "3.4.4 Ensure permissions on /etc/hosts.allow are configured"
echo "3.4.5 Ensure permissions on /etc/hosts.deny are configured"
echo "Exemption: Disable host-based connection blocking as SGs do what we need"
echo "ALL: ALL" > /etc/hosts.allow
> /etc/hosts.deny
chmod 0644 /etc/hosts.allow
chmod 0644 /etc/hosts.deny

echo "#############################################################"
echo "3.6 Firewall Configuration"
echo "3.6.1 Ensure iptables is installed"
echo "3.6.2 Ensure default deny firewall policy"
echo "3.6.3 Ensure loopback traffic is configured"
echo "3.6.4 Ensure outbound and established connections are configured"
echo "3.6.5 Ensure firewall rules exist for all open ports"
echo "Configuring iptables"
echo "Exemption:  SGs do what we need"

echo "#############################################################"
echo "4.1.1.1 Ensure audit log storage size is configured"
echo "4.1.1.2 Ensure system is disabled when audit logs are full"
# Note that in order to not fill disks with Audit Logs (which will be shipped to
# CloudWatch), we explicitly fail to meet 4.1.1.2. Instead of keeping all logs,
# we just keep the last 3 files.
echo "Configuring Auditing & Logging"
cat > /etc/audit/auditd.conf << AUDITD
max_log_file = 100
max_log_file_action = rotate
num_logs = 3
space_left_action = email
action_mail_acct = root
# OpenSCAP Rule ID auditd_data_retention_admin_space_left_action
# OpenSCAP will fail as wants "single" but CIS specifies "halt"
admin_space_left_action = halt
AUDITD

echo "#############################################################"
echo "4.1.2 Ensure auditd service is enabled"
echo "4.2.1.1 Ensure rsyslog Service is enabled"
echo "5.1.1 Ensure cron daemon is enabled"
for svc in auditd rsyslog crond; do
    chkconfig $svc on
done

echo "#############################################################"
echo "4.1.3 Ensure auditing for processes that start prior to auditd is enabled"
sed -i -e '/^-a never,task/ s/$/# /' /etc/audit/audit.rules



# pointless change













echo "#############################################################"
echo "4.1.4 Ensure events that modify date and time information are collected"
echo "4.1.5 Ensure events that modify user/group information are collected"
echo "4.1.6 Ensure events that modify the system's network environment are collected"
echo "4.1.7 Ensure events that modify the system's Mandatory Access Controls are collected"
echo "4.1.8 Ensure login and logout events are collected"
echo "4.1.9 Ensure session initiation information is collected"
echo "4.1.10 Ensure discretionary access control permission modification events are collected"
echo "4.1.11 Ensure unsuccessful unauthorized file access attempts are collected"
echo "4.1.12 Ensure use of privileged commands is collected"
echo "4.1.13 Ensure successful file system mounts are collected"
echo "4.1.14 Ensure file deletion events by users are collected"
echo "4.1.15 Ensure changes to system administration scope (sudoers) is collected"
echo "4.1.16 Ensure system administrator actions (sudolog) are collected"
echo "4.1.17 Ensure kernel module loading and unloading is collected"
echo "4.1.18 Ensure the audit configuration is immutable"
# see https://github.com/dwp/packer-infrastructure/blob/master/amazon-ebs-builder/scripts/centos7/generic/090-harden.sh#L114
cat >> /etc/audit/audit.rules << AUDITRULES
# CIS 4.1.4
# OpenSCAP Rule ID audit_rules_time_settimeofday
# OpenSCAP Rule ID audit_rules_time_stime
# Also 64bit does not have stime syscall
# OpenSCAP Rule ID audit_rules_time_adjtimex
-a always,exit -F arch=b64 -S adjtimex,settimeofday -F key=audit_time_rules
-a always,exit -F arch=b32 -S adjtimex,settimeofday -F key=audit_time_rules
-a always,exit -F arch=b32 -S stime -F key=audit_time_rules
-a always,exit -F arch=b64 -S clock_settime -F key=audit_time_rules
-a always,exit -F arch=b32 -S clock_settime -F key=audit_time_rules
-w /etc/localtime -p wa -F key=audit_time_rules

# CIS 4.1.5
# Key name is changed to match OpenSCAP requirements, but functionally is the same
-w /etc/group -p wa -k audit_rules_usergroup_modification
-w /etc/passwd -p wa -k audit_rules_usergroup_modification
-w /etc/gshadow -p wa -k audit_rules_usergroup_modification
-w /etc/shadow -p wa -k audit_rules_usergroup_modification
-w /etc/security/opasswd -p wa -k audit_rules_usergroup_modification

# CIS 4.1.6
# Key name is changed to match OpenSCAP requirements, but functionally is the same
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k audit_rules_networkconfig_modification
-a always,exit -F arch=b32 -S sethostname -S setdomainname -k audit_rules_networkconfig_modification
-w /etc/issue -p wa -k audit_rules_networkconfig_modification
-w /etc/issue.net -p wa -k audit_rules_networkconfig_modification
-w /etc/hosts -p wa -k audit_rules_networkconfig_modification
-w /etc/sysconfig/network -p wa -k audit_rules_networkconfig_modification
-w /etc/sysconfig/network-scripts/ -p wa -k audit_rules_networkconfig_modification

# CIS 4.1.7
-w /etc/selinux/ -p wa -k MAC-policy
-w /usr/share/selinux/ -p wa -k MAC-policy

# CIS 4.1.8
# OpenSCAP Rule ID audit_rules_login_events
# OpenSCAP added tallylog
-w /var/log/tallylog -p wa -k logins
-w /var/run/faillock/ -p wa -k logins
-w /var/log/lastlog -p wa -k logins

# CIS 4.1.9
# Key name is changed to match OpenSCAP requirements, but functionally is the same
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k session
-w /var/log/btmp -p wa -k session

# CIS 4.1.10
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=500 -F
auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=500 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=500 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=500 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod

# CIS 4.1.11
# OpenSCAP Rule ID audit_rules_unsuccessful_file_modification
# OpenSCAP will fail on this point as expects auid>=1000 which is less secure
-a always,exit -F arch=b32 -S creat,open,openat,open_by_handle_at,truncate,ftruncate -F exit=-EACCES -F auid>=500 -F auid!=4294967295 -F key=access
-a always,exit -F arch=b32 -S creat,open,openat,open_by_handle_at,truncate,ftruncate -F exit=-EPERM -F auid>=500 -F auid!=4294967295 -F key=access
-a always,exit -F arch=b64 -S creat,open,openat,open_by_handle_at,truncate,ftruncate -F exit=-EACCES -F auid>=500 -F auid!=4294967295 -F key=access
-a always,exit -F arch=b64 -S creat,open,openat,open_by_handle_at,truncate,ftruncate -F exit=-EPERM -F auid>=500 -F auid!=4294967295 -F key=access

# CIS 4.1.13
# OpenSCAP will fail on this point as expects auid>=1000 which is less secure
-a always,exit -F arch=b64 -S mount -F auid>=500 -F auid!=4294967295 -k mounts
-a always,exit -F arch=b32 -S mount -F auid>=500 -F auid!=4294967295 -k mounts

# CIS 4.1.14
# OpenSCAP Rule ID audit_rules_file_deletion_events
# OpenSCAP will fail on this point as expects auid>=1000 which is less secure
-a always,exit -F arch=b32 -S rmdir,unlink,unlinkat,rename -S renameat -F auid>=500 -F auid!=4294967295 -F key=delete
-a always,exit -F arch=b64 -S rmdir,unlink,unlinkat,rename -S renameat -F auid>=500 -F auid!=4294967295 -F key=delete

# CIS 4.1.15
-w /etc/sudoers -p wa -k scope
-w /etc/sudoers.d/ -p wa -k scope

# CIS 4.1.16
-w /var/log/sudo.log -p wa -k actions

# CIS 4.1.17
# OpenSCAP Rule ID audit_rules_kernel_module_loading
# CIS requires /sbin/* but OpenSCAP wants /usr/sbin and they both symlink to same place
-w /usr/sbin/insmod -p x -k modules
-w /usr/sbin/rmmod -p x -k modules
-w /usr/sbin/modprobe -p x -k modules
-a always,exit -F arch=b64 -S init_module,delete_module -F key=modules

# OpenSCAP remediation Rule ID audit_rules_sysadmin_actions
-w /etc/sudoers -p wa -k actions
-w /etc/sudoers.d/ -p wa -k actions

# CIS 4.1.18
-e 2
AUDITRULES

# OpenSCAP Rule ID audit_rules_privileged_commands
echo "# CIS 4.1.12" >> /etc/audit/audit.rules
for i in $(find / -xdev -type f -perm -4000 -o -type f -perm -2000 2>/dev/null); do
    echo "-a always,exit -F path=${i} -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged" >> /etc/audit/audit.rules
done

echo "#############################################################"
echo "4.2.1.2 Ensure logging is configured"
# CIS recommends the following:
echo "*.emerg                 :omusrmsg:*" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
echo "mail.*                  -/var/log/mail" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
echo "mail.info               -/var/log/mail.info" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
echo "mail.warning            -/var/log/mail.warn" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
echo "mail.err                 /var/log/mail.err" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
echo "news.crit               -/var/log/news/news.crit" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
echo "news.err                -/var/log/news/news.err" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
echo "news.notice             -/var/log/news/news.notice" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
echo "*.=warning;*.=err       -/var/log/warn" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
echo "*.crit                   /var/log/warn" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
echo "*.*;mail.none;news.none -/var/log/messages" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
echo "local0,local1.*         -/var/log/localmessages" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
echo "local2,local3.*         -/var/log/localmessages" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
echo "local4,local5.*         -/var/log/localmessages" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf
echo "local6,local7.*         -/var/log/localmessages" >> /etc/rsyslog.d/22-CIS-hardened-logs.conf

echo "#############################################################"
echo "4.2.1.3 Ensure rsyslog default file permissions configured"
sed -i -e 's/^$FileCreateMode.*/$FileCreateMode 0640/' /etc/rsyslog.conf
sed -i -e 's/^$FileCreateMode.*/$FileCreateMode 0640/' /etc/rsyslog.d/*.conf

echo "#############################################################"
echo "4.2.1.4 Ensure rsyslog is configured to send logs to a remote host"
echo "Exemption: all AWS instances *must* send logs to CloudWatch"

echo "#############################################################"
echo "4.2.1.5 Ensure remote rsyslog messages are only accepted on designated log hosts."
sed -i -e '/^$ModLoad imtcp/d' -e '/^$InputTCPServerRun 514/d' /etc/rsyslog.d/*.conf
sed -i -e '/^$ModLoad imtcp/d' -e '/^$InputTCPServerRun 514/d' /etc/rsyslog.conf

echo "#############################################################"
echo "4.2.2.1 Ensure syslog-ng service is enabled"
echo "4.2.2.2 Ensure logging is configured"
echo "4.2.2.3 Ensure syslog-ng default file permissions configured"
echo "4.2.2.4 Ensure syslog-ng is configured to send logs to a remote log host"
echo "4.2.2.5 Ensure remote syslog-ng messages are only accepted on designated log hosts"
echo "Exemption: We install / configure rsyslog rather than syslog-ng"

echo "#############################################################"
echo "4.2.4 Ensure permissions on all logfiles are configured"
find /var/log -type f -exec chmod 0640 {} \;

echo "#############################################################"
echo "4.3 Ensure logrotate is configured"
echo "Exemption: userdata is used to configure log rotation via logrotate"

echo "#############################################################"
echo "5.1.2 Ensure permissions on /etc/crontab are configured"
echo "5.1.3 Ensure permissions on /etc/cron.hourly are configured"
echo "5.1.4 Ensure permissions on /etc/cron.daily are configured"
echo "5.1.5 Ensure permissions on /etc/cron.weekly are configured"
echo "5.1.6 Ensure permissions on /etc/cron.monthly are configured"
chmod 0600 /etc/crontab
chmod 0600 /etc/cron.hourly
chmod 0600 /etc/cron.daily
chmod 0600 /etc/cron.weekly
chmod 0600 /etc/cron.monthly

echo "#############################################################"
echo "5.1.7 Ensure permissions on /etc/cron.d are configured"
chmod 0700 /etc/cron.d

echo "#############################################################"
echo "5.1.8 Ensure at/cron is restricted to authorized users"
rm -f /etc/cron.deny /etc/at.deny
touch /etc/cron.allow /etc/at.allow
chmod 0600 /etc/cron.allow /etc/at.allow
chown root:root /etc/cron.allow /etc/at.allow

echo "#############################################################"
echo "5.2.1 Ensure permissions on /etc/ssh/sshd_config are configured"
chown root:root /etc/ssh/sshd_config
chmod 0600 /etc/ssh/sshd_config

echo "#############################################################"
echo "5.2.2 Ensure SSH Protocol is set to 2"
echo "5.2.3 Ensure SSH LogLevel is set to INFO"
echo "5.2.4 Ensure SSH X11 forwarding is disabled"
echo "5.2.5 Ensure SSH MaxAuthTries is set to 4 or less"
echo "5.2.6 Ensure SSH IgnoreRhosts is enabled"
echo "5.2.7 Ensure SSH HostbasedAuthentication is disabled"
echo "5.2.8 Ensure SSH root login is disabled"
echo "5.2.9 Ensure SSH PermitEmptyPasswords is disabled"
echo "5.2.10 Ensure SSH PermitUserEnvironment is disabled"
echo "5.2.11 Ensure only approved MAC algorithms are used"
echo "5.2.12 Ensure SSH Idle Timeout Interval is configured"
echo "5.2.13 Ensure SSH LoginGraceTime is set to one minute or less"
echo "5.2.14 Ensure SSH access is limited"
echo "5.2.15 Ensure SSH warning banner is configured"
echo "Configuring SSH"
echo Create sshusers and no-ssh-access groups
groupadd sshusers || true
groupadd no-ssh-access || true

echo add ec2-user to sshusers group to allow access
usermod -a -G sshusers ec2-user

echo apply hardened SSHD config
cat > /etc/ssh/sshd_config << SSHCONFIG
Port 22
ListenAddress 0.0.0.0
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
UsePrivilegeSeparation yes
KeyRegenerationInterval 3600
ServerKeyBits 2048
SyslogFacility AUTH
LogLevel INFO
ClientAliveInterval 300
ClientAliveCountMax 0
LoginGraceTime 60
PermitRootLogin no
StrictModes yes
MaxAuthTries 4
MaxSessions 10
RSAAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysCommand /usr/bin/sss_ssh_authorizedkeys
AuthorizedKeysCommandUser nobody
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
PasswordAuthentication no
KerberosAuthentication no
GSSAPIAuthentication yes
GSSAPICleanupCredentials yes
X11Forwarding no
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
Banner /etc/issue
AcceptEnv LANG LC_* XMODIFIERS
Subsystem sftp    /usr/libexec/openssh/sftp-server
UsePAM yes
UseDNS no
DenyUsers no-ssh-access
AllowGroups sshusers
# OpenSCAP Rule ID sshd_use_approved_ciphers
# OpenSCAP will fail with this cipher set, but ours is more strict
Ciphers aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com
PermitUserEnvironment no
SSHCONFIG

echo "#############################################################"
echo "5.3.1 Ensure password creation requirements are configured"
echo "5.3.2 Ensure lockout for failed password attempts is configured"
echo "5.3.3 Ensure password reuse is limited"
echo "5.3.4 Ensure password hashing algorithm is SHA-512"
# See https://git.ucd.gpn.gov.uk/dip/aws-common-infrastructure/wiki/Access-Management-Policy#regular-users
sed -i 's/^# minlen.*$/minlen = 24/' /etc/security/pwquality.conf
sed -i 's/^# difok.*$/difok = 1/' /etc/security/pwquality.conf
# AL1 defaults are generally better than CIS requirements
# 5.3.1 - Check /etc/pam.d/password-auth and /etc/pam.d/system-auth contain:
# password requisite pam_pwquality.so try_first_pass retry=3
# 5.3.2 - Ensure lockout for failed password attempts is configured
# auth required pam_faillock.so preauth audit silent deny=10 unlock_time=900
# auth [success=1 default=bad] pam_unix.so
# auth [default=die] pam_faillock.so authfail audit deny=10 unlock_time=900
# auth sufficient pam_faillock.so authsucc audit deny=10 unlock_time=900
# OpenSCAP Rule ID accounts_passwords_pam_faillock_deny will fail (we deny at 10 in line with our policy)
# OpenSCAP Rule ID removed nullok entries
cat > /etc/pam.d/system-auth << PAMSYSCONFIG
auth        required                   pam_env.so
auth        required                   pam_faildelay.so delay=2000000
auth        required                   pam_faillock.so preauth audit silent deny=10 unlock_time=900
auth        sufficient                 pam_unix.so try_first_pass
auth        sufficient                 pam_faillock.so authsucc audit deny=10 unlock_time=900
auth        requisite                  pam_succeed_if.so uid >= 500 quiet_success
auth        required                   pam_deny.so
auth        [success=1 default=bad]    pam_unix.so
auth        [default=die]              pam_faillock.so authfail audit deny=10 unlock_time=900

account     required                   pam_faillock.so
account     required                   pam_unix.so
account     sufficient                 pam_localuser.so
account     sufficient                 pam_succeed_if.so uid < 500 quiet
account     required                   pam_permit.so

password    requisite                  pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
password    sufficient                 pam_unix.so sha512 shadow try_first_pass use_authtok remember=5
password    required                   pam_deny.so

session     optional                   pam_keyinit.so revoke
session     required                   pam_limits.so
-session    optional                   pam_systemd.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required                   pam_unix.so
PAMSYSCONFIG

echo "#############################################################"
echo "5.4.1.1 Ensure password expiration is 365 days or less"
echo "Whilst no users will be logging on to this system, our policy is 90 days for regular users and 365 for machine users"
# Refs: https://git.ucd.gpn.gov.uk/dip/aws-common-infrastructure/wiki/Access-Management-Policy#regular-users
#       https://git.ucd.gpn.gov.uk/dip/aws-common-infrastructure/wiki/Access-Management-Policy#machine-accounts
sed -i 's/^PASS_MAX_DAYS.*$/PASS_MAX_DAYS 90/' /etc/login.defs

echo "#############################################################"
echo "5.4.1.2 Ensure minimum days between password changes is 7 or more"
sed -i 's/^PASS_MIN_DAYS.*$/PASS_MIN_DAYS 7/' /etc/login.defs

echo "#############################################################"
echo "5.4.1.3 Ensure password expiration warning days is 7 or more"
    sed -i 's/^PASS_WARN_AGE.*$/PASS_WARN_AGE 7/' /etc/login.defs

echo "#############################################################"
echo "5.4.1.4 Ensure inactive password lock is 30 days or less"
useradd -D -f 30

echo "#############################################################"
echo "5.4.1.5 Ensure all users last password change date is in the past"
echo "Exemption: we have no users that we configure with passwords"

echo "#############################################################"
echo "5.4.2 Ensure system accounts are non-login"
echo "Exemption: No users in AL1 have this, CWA adds it later but we have dealt with this upstream"

echo "#############################################################"
echo "5.4.3 Ensure default group for the root account is GID 0"
usermod -g 0 root

echo "#############################################################"
echo "5.4.4 Ensure default user umask is 027 or more restrictive"
sed -i 's/^.*umask 0.*$/umask 027/' /etc/bashrc
sed -i 's/^.*umask 0.*$/umask 027/' /etc/profile
sed -i 's/^.*umask 0.*$/umask 027/' /etc/profile.d/*.sh

echo "#############################################################"
echo "5.4.5 Ensure default user shell timeout is 900 seconds or less"
echo 'TMOUT=600' >> /etc/bashrc
echo 'TMOUT=600' >> /etc/profile

echo "#############################################################"
echo "5.5 Ensure access to the su command is restricted"
sed -i '/#auth.*required.*pam_wheel.so/s/^# *//' /etc/pam.d/su

echo "#############################################################"
echo "6.1.1 Audit system file permissions"
echo "Exemption: We are not auditing all system files, unscored"

echo "#############################################################"
echo "6.1.2 Ensure permissions on /etc/passwd are configured"
chown root:root /etc/passwd
chmod 644 /etc/passwd

echo "#############################################################"
echo "6.1.3 Ensure permissions on /etc/shadow are configured"
chown root:root /etc/shadow
chmod 000 /etc/shadow

echo "#############################################################"
echo "6.1.4 Ensure permissions on /etc/group are configured"
chown root:root /etc/group
chmod 644 /etc/group

echo "#############################################################"
echo "6.1.5 Ensure permissions on /etc/gshadow are configured"
chown root:root /etc/gshadow
chmod 000 /etc/gshadow

echo "#############################################################"
echo "6.1.6 Ensure permissions on /etc/passwd-are configured"
chown root:root /etc/passwd-
chmod u-x,go-wx /etc/passwd-

echo "#############################################################"
echo "6.1.7 Ensure permissions on /etc/shadow-are configured"
chown root:root /etc/shadow-
chmod 000 /etc/shadow-

echo "#############################################################"
echo "6.1.8 Ensure permissions on /etc/group-are configured"
chown root:root /etc/group-
chmod u-x,go-wx /etc/group-

echo "#############################################################"
echo "6.1.9 Ensure permissions on /etc/gshadow-are configured "
chown root:root /etc/gshadow-
chmod 000 /etc/gshadow-

echo "#############################################################"
echo "6.1.10 Ensure no world writable files exist"
echo "Expect: no output"
# OpenSCAP Rule ID file_permissions_unauthorized_world_writable will fail (have verified there is no output for command)
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type f -perm -0002

echo "#############################################################"
echo "6.1.11 Ensure no unowned files or directories exist"
echo "Expect: no output"
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nouser

echo "#############################################################"
echo "6.1.12 Ensure no ungrouped files or directories exist"
echo "Expect: no output"
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nogroup

echo "#############################################################"
echo "6.1.13 Audit SUID executables"
# OpenSCAP Rule ID file_permissions_unauthorized_suid
echo "Exemption: we are not auditing all system files, unscored"

echo "#############################################################"
echo "6.1.14 Audit SGID executables"
# OpenSCAP Rule ID file_permissions_unauthorized_sgid
echo "Exemption: we are not auditing all system files, unscored"

echo "#############################################################"
echo "6.2.1 Ensure password fields are not empty"
echo "Expect: no output"
cat /etc/shadow | awk -F: '($2 == "" ) { print $1 " does not have a password "}'

echo "#############################################################"
echo "6.2.2 Ensure no legacy '+' entries exist in /etc/passwd"
echo "Expect: no output"
grep '^\+:' /etc/passwd || true

echo "#############################################################"
echo "6.2.3 Ensure no legacy '+' entries exist in /etc/shadow"
echo "Expect: no output"
grep '^\+:' /etc/shadow || true

echo "#############################################################"
echo "6.2.4 Ensure no legacy '+' entries exist in /etc/group"
echo "Expect: no output"
grep '^\+:' /etc/group || true

echo "#############################################################"
echo "6.2.5 Ensure root is the only UID 0 account"
echo "Expect: root"
cat /etc/passwd | awk -F: '($3 == 0) { print $1 }'

echo "#############################################################"
echo "6.2.6 Ensure root PATH Integrity"
echo "Expect: no '.' or other writeable directory in PATH"
echo $PATH

echo "#############################################################"
echo "6.2.7 Ensure all users' home directories exist"
echo "Expect: all users to have home folders"
cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }'

echo "#############################################################"
echo "6.2.8 Ensure users' home directories permissions are 750 or more restrictive"
echo "Expect: no output"
cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
  if [ ! -d "$dir" ]; then
    echo "The home directory ($dir) of user $user does not exist."
  else
    dirperm=`ls -ld $dir | cut -f1 -d" "`
    if [ `echo $dirperm | cut -c6` != "-" ]; then
      echo "Group Write permission set on the home directory ($dir) of user $user"
    fi
    if [ `echo $dirperm | cut -c8` != "-" ]; then
      echo "Other Read permission set on the home directory ($dir) of user $user"
    fi
    if [ `echo $dirperm | cut -c9` != "-" ]; then
      echo "Other Write permission set on the home directory ($dir) of user $user"
    fi
    if [ `echo $dirperm | cut -c10` != "-" ]; then
      echo "Other Execute permission set on the home directory ($dir) of user $user"
    fi
  fi
done

echo "#############################################################"
echo "6.2.9 Ensure users own their home directories"
echo "Expect: no output"
cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
  if [ ! -d "$dir" ]; then
    echo "The home directory ($dir) of user $user does not exist."
  else
    owner=$(stat -L -c "%U" "$dir")
    if [ "$owner" != "$user" ]; then
      echo "The home directory ($dir) of user $user is owned by $owner."
    fi
  fi
done

echo "#############################################################"
echo "6.2.10 Ensure users' dot files are not group or world writable"
echo "Expect: no output"
cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
  if [ ! -d "$dir" ]; then
    echo "The home directory ($dir) of user $user does not exist."
  else
    for file in $dir/.[A-Za-z0-9]*; do
      if [ ! -h "$file" -a -f "$file" ]; then
        fileperm=`ls -ld $file | cut -f1 -d" "`
        if [ `echo $fileperm | cut -c6` != "-" ]; then
          echo "Group Write permission set on file $file"
        fi
        if [ `echo $fileperm | cut -c9`  != "-" ]; then
          echo "Other Write permission set on file $file"
        fi
      fi
    done
  fi
done

echo "#############################################################"
echo "6.2.11 Ensure no users have .forward files"
echo "Expect: no output"
cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
  if [ ! -d "$dir" ]; then
    echo "The home directory ($dir) of user $user does not exist."
  else
    if [ ! -h "$dir/.forward" -a -f "$dir/.forward" ]; then
      echo ".forward file $dir/.forward exists"
    fi
  fi
done

echo "#############################################################"
echo "6.2.12 Ensure no users have .netrc files"
echo "Expect: no output"
cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
  if [ ! -d "$dir" ]; then
    echo "The home directory ($dir) of user $user does not exist."
  else
    if [ ! -h "$dir/.netrc" -a -f "$dir/.netrc" ]; then
      echo ".netrc file $dir/.netrc exists"
    fi
  fi
done

echo "#############################################################"
echo "6.2.13 Ensure users' .netrc Files are not group or world accessible"
echo "Expect: no output"
cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
  if [ ! -d "$dir" ]; then
    echo "The home directory ($dir) of user $user does not exist."
  else
    for file in $dir/.netrc; do
      if [ ! -h "$file" -a -f "$file" ]; then
        fileperm=`ls -ld $file | cut -f1 -d" "`
        if [ `echo $fileperm | cut -c5`  != "-" ]; then
          echo "Group Read set on $file"
        fi
        if [ `echo $fileperm | cut -c6`  != "-" ]; then
          echo "Group Write set on $file"
        fi
        if [ `echo $fileperm | cut -c7`  != "-" ]; then
          echo "Group Execute set on $file"
        fi
        if [ `echo $fileperm | cut -c8`  != "-" ]; then
          echo "Other Read set on $file"
        fi
        if [ `echo $fileperm | cut -c9`  != "-" ]; then
          echo "Other Write set on $file"
        fi
        if [ `echo $fileperm | cut -c10`  != "-" ]; then
          echo "Other Execute set on $file"
        fi
      fi
    done
  fi
done

echo "#############################################################"
echo "6.2.14 Ensure no users have .rhosts files"
echo "Expect: no output"
cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
  if [ ! -d "$dir" ]; then
    echo "The home directory ($dir) of user $user does not exist."
  else
    for file in $dir/.rhosts; do
      if [ ! -h "$file" -a -f "$file" ]; then
        echo ".rhosts file in $dir"
      fi
    done
  fi
done

echo "#############################################################"
echo "6.2.15 Ensure all groups in /etc/passwd exist in /etc/group"
echo "Expect: no output"
for i in $(cut -s -d: -f4 /etc/passwd | sort -u ); do
  grep -q -P "^.*?:[^:]*:$i:" /etc/group
  if [ $? -ne 0 ]; then
   echo "Group $i is referenced by /etc/passwd but does not exist in /etc/group"
  fi
done

echo "#############################################################"
echo "6.2.16 Ensure no duplicate UIDs exist"
echo "Expect: no output"
cat /etc/passwd | cut -f3 -d":" | sort -n | uniq -c | while read x ; do
  [ -z "${x}" ] && break
  set - $x
  if [ $1 -gt 1 ]; then
    users= `awk -F: '($3 == n) { print $1 }' n=$2 /etc/passwd | xargs`
    echo "Duplicate UID ($2): ${users}"
  fi
done

echo "#############################################################"
echo "6.2.17 Ensure no duplicate GIDs exist"
cat /etc/group | cut -f3 -d":" | sort -n | uniq -c | while read x ; do
  [ -z "${x}" ] && break
  set - $x
  if [ $1 -gt 1 ]; then
    groups= `awk -F: '($3 == n) { print $1 }' n=$2 /etc/group | xargs`
    echo "Duplicate GID ($2): ${groups}"
  fi
done

echo "#############################################################"
echo "6.2.18 Ensure no duplicate user names exist"
echo "Expect: no output"
cat /etc/passwd | cut -f1 -d":" | sort -n | uniq -c | while read x ; do
  [ -z "${x}" ] && break
  set - $x
  if [ $1 -gt 1 ]; then
    uids= `awk -F: '($1 == n) { print $3 }' n=$2 /etc/passwd | xargs`
    echo "Duplicate User Name ($2): ${uids}"
  fi
done

echo "#############################################################"
echo "6.2.19 Ensure no duplicate group names exist"
echo "Expect: no output"
cat /etc/group | cut -f1 -d":" | sort -n | uniq -c | while read x ; do
  [ -z "${x}" ] && break
  set - $x
  if [ $1 -gt 1 ]; then
    gids= `gawk -F: '($1 == n) { print $3 }' n=$2 /etc/group | xargs`
    echo "Duplicate Group Name ($2): ${gids}"
  fi
done


# OpenSCAP fix for Rule ID no_direct_root_logins
> /etc/securetty
# This should empty this file, however ttyS0 will always be added back in as it is a
# built-in that's ensuring there can be a root logon to console, which cannot happen in AWS

# OpenSCAP Rule ID mount_option_dev_shm_noexec will fail (we exempt partitioning)
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

sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/sysconfig/selinux
