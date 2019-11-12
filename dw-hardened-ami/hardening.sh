#!/bin/sh

# Hardens an Amazon Linux AMI according to CIS Amazon Linux Benchmark v2.1.0

set -eEu

echo "1 Initial Setup"

echo "1.1 Filesystem Configuration"

# 1.1.1.1, 1.1.1.2, 1.1.1.3, 1.1.1.4, 1.1.1.5, 1.1.1.6, 1.1.1.7, 1.1.1.8,
# 3.5.1, 3.5.2 3.5.3 3.5.4
echo "1.1.1.1 - 1.1.1.8 Disable Unused Filesystems"
> /etc/modprobe.d/CIS.conf
for fs in cramfs freevxfs jffs2 hfs hfsplus squashfs udf vfat \
    dccp sctp tipc; do
    echo "install $fs /bin/true" >> /etc/modprobe.d/CIS.conf
done

# 1.1.2, 1.1.3, 1.1.4, 1.1.5, 1.1.6, 1.1.7, 1.1.8, 1.1.9, 1.1.10, 1.1.11,
# 1.1.12, 1.1.13, 1.1.14, 1.1.15, 1.1.16, 1.1.17
echo "1.1.2 - 1.1.17 Partitioning & Mounting"
echo "Temporary exemption; we're not sure that partioning provides much value for single-use instances"

# 1.1.18
echo "1.1.18 Set sticky bit on all world-writable directories"
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | xargs chmod a+t

# 1.1.19, 2.1.1, 2.1.2, 2.1.3, 2.1.4, 2.1.5, 2.1.6, 2.1.7, 2.1.8, 2.1.9, 2.1.10,
# 2.1.11, 2.2.3, 2.2.4, 2.2.5, 2.2.6, 2.2.7, 2.2.8, 2.2.9, 2.2.10, 2.2.11,
# 2.2.12, 2.2.13, 2.2.14, 2.2.15, 2.2.16
echo "Disabling unnecessary services"
echo "Only installed services are rpcbind and rsync"
for svc in rpcbind rsync; do
    chkconfig $svc off
done;


# 1.2.1, 1.2.2, 1.2.3
echo "1.2 Configure Software Updates"
echo "Exemption; in-life instances require no access to package repositories; they'll be rebuilt from refreshed AMIs"

# 1.3.1, 1.6.2, 2.2.1.1, 3.4.1, 3.6.1, 4.2.3
echo "Installing required packages"
yum install -y \
  aide \
  libselinux \
  tcp_wrappers \
  iptables \
  rsyslog

echo "1.3.1 Ensure AIDE is installed"
aide --init
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

echo "1.3.2 Ensure filesystem integrity is regularly checked"
(crontab -l 2>/dev/null; echo "0 5 * * * /usr/sbin/aide --check") | crontab -

echo "1.4 Secure Boot Settings"
echo "1.4.1 Ensure permissions on bootloader config are configured"
chown root:root /boot/grub/menu.lst
chmod 0600 /boot/grub/menu.lst

echo "1.4.2 Ensure authentication required for single user mode"
echo "Exemption; AWS instances do not allow access to the bootloader or console when the instance is started."

echo "1.4.3 Ensure interactive boot is not enabled"
echo "PROMPT=NO" >> /etc/sysconfig/init

echo "1.5 Additional process hardening"
echo "1.5.1 Ensure core dumps are restricted"
echo "* hard core 0" > /etc/security/limits.d/CIS.conf

echo "Tweaking sysctl knobs"
# 1.5.1, 1.5.3, 3.1.1, 3.1.2, 3.2.1, 3.2.2, 3.2.3, 3.2.4, 3.2.5, 3.2.6, 3.2.7,
# 3.2.8, 3.3.1, 3.3.2
cat > /etc/sysctl.d/CIS.conf << SYSCTL
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

# 1.5.2 is check-only; should be caught by OpenSCAP & Lynis

# 1.5.4, 1.6.1.4, 1.6.1.5, 2.2.1.1, 2.2.2, 2.3.1, 2.3.2, 2.3.3, 2.3.4, 2.3.5
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


# 1.6.1.1 is check-only; should be caught by OpenSACP & Lynis
# 1.6.1.2, 1.6.1.3
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

sed -i -e 's/selinux=0/selinux=1 security=selinux/' /boot/grub/menu.lst

# Create AutoRelabel
touch /.autorelabel

# 1.6.1.6 is check-only; should be caught by OpenSACP & Lynis

echo "1.7 Warning Banners"
echo "1.7.1 Command Line Warning Banners"
echo "1.7.1.1 Ensure message of the day is configured properly"
# Ensure /etc/motd contains nothing; we want to display a warning *before* login
# in compliance with DWP norms (see 1.7.1.2 below)
> /etc/motd

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

echo "1.7.1.3 Ensure remote login warning banner is configured properly"
# We don't intend to allow remote logins, but this meets CIS compliance and
# ensures compliance with DWP norms if we do decide to enable remote logins
cp /etc/issue /etc/issue.net

echo "1.7.1.4, 1.7.1.5, 1.7.1.6 Ensure permissions on login warning banners are configured"
chmod 0644 /etc/motd
chmod 0644 /etc/issue
chmod 0644 /etc/issue.net

echo "1.8 Ensure patches, updates, and additional security software are installed"
echo "Excluded from hardening.sh, added to Userdata due to build time constraints"
# yum update -y

echo "2.2.1.2 Ensure ntp is configured"
echo "Exemption; Amazon Linux recommends chrony"
# TODO: Harden ntpd configuration

echo "2.2.1.3 Ensure chrony is configured"
echo "Chrony not installed"

echo "2.2.15 Ensure mail transfer agent is configured for local-only mode"
# TODO: Check inet_interfaces = loopback-only exists in /etc/postfix/main.cf

echo "3.3.3 Disable ipv6"
# TODO: Edit /boot/grub/grub.conf to include ipv6.disable=1 on all kernel lines and defaults for newly installed kernels

# Disable host-based connection blocking as SGs do what we need
# 3.4.2, 3.4.3, 3.4.4, 3.4.5
echo "ALL: ALL" > /etc/hosts.allow
> /etc/hosts.deny
chmod 0644 /etc/hosts.allow
chmod 0644 /etc/hosts.deny

# 3.6.2, 3.6.3, 3.6.4, 3.6.5
echo "Configuring iptables"
echo "Exemption; SG rules are enough"

# 4.1.1.1, 4.1.1.2
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
admin_space_left_action = halt
AUDITD

# 4.1.2, 4.2.1.1, 5.1.1
for svc in auditd rsyslog crond; do
    chkconfig $svc on
done

# 4.1.3
# TODO: Edit /boot/grub/grub.conf to include audit=1 on all kernel lines (and defaults for newly installed kernels)

# TODO - check default /etc/audit/audit.rules to see if any need deleting
# see https://github.com/dwp/packer-infrastructure/blob/master/amazon-ebs-builder/scripts/centos7/generic/090-harden.sh#L114
cat > /etc/audit/rules.d/audit.rules << AUDITRULES
# CIS 4.1.4
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time- change
-a always,exit -F arch=b64 -S clock_settime -k time-change
-a always,exit -F arch=b32 -S clock_settime -k time-change
-w /etc/localtime -p wa -k time-change

# CIS 4.1.5
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity

# CIS 4.1.6
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale -a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale -w /etc/issue -p wa -k system-locale
-w /etc/issue.net -p wa -k system-locale
-w /etc/hosts -p wa -k system-locale
-w /etc/sysconfig/network -p wa -k system-locale
-w /etc/sysconfig/network-scripts/ -p wa -k system-locale

# CIS 4.1.7
-w /etc/selinux/ -p wa -k MAC-policy
-w /usr/share/selinux/ -p wa -k MAC-policy

# CIS 4.1.8
-w /var/log/lastlog -p wa -k logins
-w /var/run/faillock/ -p wa -k logins

# CIS 4.1.9
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k logins
-w /var/log/btmp -p wa -k logins

# CIS 4.1.10
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=500 -F
auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=500 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=500 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=500 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod

# CIS 4.1.11
-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=500 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=500 -F auid!=4294967295 -k access
-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=500 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=500 -F auid!=4294967295 -k access

# CIS 4.1.13
-a always,exit -F arch=b64 -S mount -F auid>=500 -F auid!=4294967295 -k mounts
-a always,exit -F arch=b32 -S mount -F auid>=500 -F auid!=4294967295 -k mounts

# CIS 4.1.14
-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=500 -F auid!=4294967295 -k delete
-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=500 -F auid!=4294967295 -k delete

# CIS 4.1.15
-w /etc/sudoers -p wa -k scope
-w /etc/sudoers.d/ -p wa -k scope

# CIS 4.1.16
-w /var/log/sudo.log -p wa -k actions

# CIS 4.1.17
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules
-a always,exit -F arch=b64 -S init_module -S delete_module -k modules

# CIS 4.1.18
-e 2
AUDITRULES

echo "# CIS 4.1.12" >> /etc/audit/rules.d/audit.rules
for i in $(find / -xdev -type f -perm -4000 -o -type f -perm -2000 2>/dev/null); do
    echo "-a always,exit -F path=${i} -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged" >> /etc/audit/rules.d/audit.rules
done

# 4.2.1.2
# TODO - check the contents of /etc/rsyslog.conf & /etc/rsyslog.d/*.conf
# CIS recommends the following:
# *.emerg                 :omusrmsg:*
# mail.*                  -/var/log/mail
# mail.info               -/var/log/mail.info
# mail.warning            -/var/log/mail.warn
# mail.err                 /var/log/mail.err
# news.crit               -/var/log/news/news.crit
# news.err                -/var/log/news/news.err
# news.notice             -/var/log/news/news.notice
# *.=warning;*.=err       -/var/log/warn
# *.crit                   /var/log/warn
# *.*;mail.none;news.none -/var/log/messages
# local0,local1.*         -/var/log/localmessages
# local2,local3.*         -/var/log/localmessages
# local4,local5.*         -/var/log/localmessages
# local6,local7.*         -/var/log/localmessages

# 4.2.1.3
# TODO - also check this isn't being set in any /etc/rsyslog.d/*.conf files
sed -i -e 's/^$FileCreateMode.*/$FileCreateMode 0640/' /etc/rsyslog.conf

echo "4.2.1.4 Ensure rsyslog is configured to send logs to a remote host"
echo "Exemption; all AWS instances *must* send logs to CloudWatch"

# 4.2.1.5
# TODO - also check there aren't any mentions of this in any /etc/rsyslog.d/*.conf files
sed -i -e '/^$ModLoad imtcp/d' -e '/^$InputTCPServerRun 514/d' /etc/rsyslog.conf

# 4.2.2.1, 4.2.2.2, 4.2.2.3, 4.2.2.4, 4.2.2.5 are exempt; we install/configure
# rsyslog rather than syslog-ng


# 4.2.4
find /var/log -type f -exec chmod 0640 {} \;

# 4.3 - nothing to do here; userdata will configure log rotation via logrotate
# TODO: Are there any common configs we can lay down here that will minimise
# the amount of copy-paste required in each userdata script?

# 5.1.2, 5.1.3, 5.1.4, 5.1.5, 5.1.6
chmod 0600 /etc/crontab
chmod 0600 /etc/cron.hourly
chmod 0600 /etc/cron.daily
chmod 0600 /etc/cron.weekly
chmod 0600 /etc/cron.monthly

# 5.1.7
chmod 0700 /etc/cron.d

# 5.1.8
rm -f /etc/cron.deny /etc/at.deny
touch /etc/cron.allow /etc/at.allow
chmod 0600 /etc/cron.allow /etc/at.allow
chown root:root /etc/cron.allow /etc/at.allow

# 5.2.1
chown root:root /etc/ssh/sshd_config
chmod 0600 /etc/ssh/sshd_config

# 5.2.2, 5.2.3, 5.2.4, 5.2.5, 5.2.6, 5.2.7, 5.2.8, 5.2.9, 5.2.10, 5.2.11,
# 5.2.12, 5.2.13, 5.2.14, 5.2.15
echo "Configuring SSH"
echo Create sshusers and no-ssh-access groups
groupadd sshusers
groupadd no-ssh-access

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
Banner /etc/issue.net
AcceptEnv LANG LC_* XMODIFIERS
Subsystem sftp    /usr/libexec/openssh/sftp-server
UsePAM yes
UseDNS no
DenyUsers no-ssh-access
AllowGroups sshusers
Ciphers aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com
PermitUserEnvironment no
SSHCONFIG

echo "5.3.1 - Ensure password creation requirements are configured...."
# See https://git.ucd.gpn.gov.uk/dip/aws-common-infrastructure/wiki/Access-Management-Policy#regular-users
sed -i 's/^# minlen.*$/minlen = 24/' /etc/security/pwquality.conf
sed -i 's/^# difok.*$/difok = 1/' /etc/security/pwquality.conf

# TODO:
# Check /etc/pam.d/password-auth and /etc/pam.d/system-auth contain:
# password requisite pam_pwquality.so try_first_pass retry=3

# 5.3.2
# TODO: Check /etc/pam.d/password-auth and /etc/pam.d/system-auth contain the
# following:
#
# auth required pam_faillock.so preauth audit silent deny=10 unlock_time=900
# auth [success=1 default=bad] pam_unix.so
# auth [default=die] pam_faillock.so authfail audit deny=10 unlock_time=900
# auth sufficient pam_faillock.so authsucc audit deny=10 unlock_time=900

# 5.3.3
# TODO: Check /etc/pam.d/password-auth and /etc/pam.d/system-auth contain the
# following:
# password sufficient pam_unix.so remember=24
