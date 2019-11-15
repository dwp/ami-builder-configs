#!/bin/sh

# Hardens an Amazon Linux AMI according to CIS Amazon Linux Benchmark v2.1.0

set -eEu

echo "1.1.1.1 - 1.1.1.8 Disable Unused Filesystems"
echo "3.5.1, 3.5.2 3.5.3 3.5.4"
> /etc/modprobe.d/CIS.conf
for fs in cramfs freevxfs jffs2 hfs hfsplus squashfs udf vfat \
    dccp sctp tipc; do
    echo "install $fs /bin/true" >> /etc/modprobe.d/CIS.conf
done

echo "1.1.2 - 1.1.17 Partitioning & Mounting"
echo "Temporary exemption; we're not sure that partioning provides much value for single-use instances"

echo "1.1.18 Set sticky bit on all world-writable directories"
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | xargs chmod a+t

echo "1.1.19, 2.1.1, 2.1.2, 2.1.3, 2.1.4, 2.1.5, 2.1.6, 2.1.7, 2.1.8, 2.1.9, 2.1.10"
echo "2.1.11, 2.2.3, 2.2.4, 2.2.5, 2.2.6, 2.2.7, 2.2.8, 2.2.9, 2.2.10, 2.2.11"
echo "2.2.12, 2.2.13, 2.2.14, 2.2.15, 2.2.16"
echo "Disabling unnecessary services"
echo "Only installed services are rpcbind and rsync"
for svc in rpcbind rsync; do
    chkconfig $svc off
done;

echo "1.2.1, 1.2.2, 1.2.3"
echo "1.2 Configure Software Updates"
echo "Exemption; in-life instances require no access to package repositories; they'll be rebuilt from refreshed AMIs"

echo "1.3.1, 1.6.2, 2.2.1.1, 3.4.1, 3.6.1, 4.2.3"
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

echo "# 1.5.1, 1.5.3, 3.1.1, 3.1.2, 3.2.1, 3.2.2, 3.2.3, 3.2.4, 3.2.5, 3.2.6, 3.2.7"
echo "3.2.8, 3.3.1, 3.3.2"
echo "Tweaking sysctl knobs"
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

echo "1.5.2 Ensure XD/NX support is enabled"
echo "Expect: active"
dmesg | grep NX

echo "1.5.4, 1.6.1.4, 1.6.1.5, 2.2.1.1, 2.2.2, 2.3.1, 2.3.2, 2.3.3, 2.3.4, 2.3.5"
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


echo "1.6.1.1 - Ensure SELinux is not disabled in bootloader configuration"
echo "Expect: no setting with selinux=0 or enforcing=0"
grep "^\s*kernel" /boot/grub/menu.lst

echo "1.6.1.2, 1.6.1.3"
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

echo "1.6.1.6 - Ensure no unconfined daemons exist"
echo "Expect: no output"
ps -eZ | egrep "initrc" | egrep -vw "tr|ps|egrep|bash|awk" | tr ':' ' ' | awk '{ print $NF }'

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
echo "Excluded from hardening.sh, added to Userdata in General AMI due to build time constraints"
# yum update -y


echo "2.2.1.2 Ensure ntp is configured"
# AL1 defaults to pre-hardened ntpd configuration

echo "2.2.1.3 Ensure chrony is configured"
echo "Chrony not installed"

echo "2.2.15 Ensure mail transfer agent is configured for local-only mode"
# Check inet_interfaces = loopback-only exists in /etc/postfix/main.cf <- File not present on default AL1 instance
# AL1 appears to use sendmail rather than postfix
# netstat -an | grep LIST | grep ":25[[:space:]]" <- to check sendmail is in local-only mode, is default for AL1
echo "Expect 'DaemonPortOptions=Port=smtp,Addr=127.0.0.1, Name=MTA'"
cat /etc/mail/sendmail.cf | grep DaemonPortOptions

echo "3.3.3 Disable ipv6"
sed -i -e '/^kernel/ s/$/ ipv6.disable=1/' /boot/grub/grub.conf

echo "3.4.2, 3.4.3, 3.4.4, 3.4.5 - Disable host-based connection blocking as SGs do what we need"
echo "ALL: ALL" > /etc/hosts.allow
> /etc/hosts.deny
chmod 0644 /etc/hosts.allow
chmod 0644 /etc/hosts.deny

echo "3.6.2, 3.6.3, 3.6.4, 3.6.5"
echo "Configuring iptables"
echo "Exemption; SG rules are enough"

echo "4.1.1.1, 4.1.1.2"
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

echo "4.1.2, 4.2.1.1, 5.1.1"
for svc in auditd rsyslog crond; do
    chkconfig $svc on
done

echo "4.1.3 - Ensure auditing for processes that start prior to auditd is enabled"
sed -i -e '/^kernel/ s/$/ audit=1/' /boot/grub/grub.conf
sed -i -e '/^-a never,task/ s/$/# /' /etc/audit/audit.rules

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

echo "4.2.1.2 - Ensure logging is configured"
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

echo "4.2.1.3 - Ensure rsyslog default file permissions configured"
sed -i -e 's/^$FileCreateMode.*/$FileCreateMode 0640/' /etc/rsyslog.conf
sed -i -e 's/^$FileCreateMode.*/$FileCreateMode 0640/' /etc/rsyslog.d/*.conf

echo "4.2.1.4 - Ensure rsyslog is configured to send logs to a remote host"
echo "Exemption; all AWS instances *must* send logs to CloudWatch"

echo "4.2.1.5 - Ensure remote rsyslog messages are only accepted on designated log hosts."
sed -i -e '/^$ModLoad imtcp/d' -e '/^$InputTCPServerRun 514/d' /etc/rsyslog.d/*.conf
sed -i -e '/^$ModLoad imtcp/d' -e '/^$InputTCPServerRun 514/d' /etc/rsyslog.conf

# 4.2.2.1, 4.2.2.2, 4.2.2.3, 4.2.2.4, 4.2.2.5 are exempt; we install/configure
# rsyslog rather than syslog-ng

echo "4.2.4 - Ensure permissions on all logfiles are configured"
find /var/log -type f -exec chmod 0640 {} \;

# 4.3 -userdata will configure log rotation via logrotate

echo "5.1.2, 5.1.3, 5.1.4, 5.1.5, 5.1.6"
chmod 0600 /etc/crontab
chmod 0600 /etc/cron.hourly
chmod 0600 /etc/cron.daily
chmod 0600 /etc/cron.weekly
chmod 0600 /etc/cron.monthly

echo "5.1.7 - Ensure permissions on /etc/cron.d are configured"
chmod 0700 /etc/cron.d

echo "5.1.8 - Ensure at/cron is restricted to authorized users"
rm -f /etc/cron.deny /etc/at.deny
touch /etc/cron.allow /etc/at.allow
chmod 0600 /etc/cron.allow /etc/at.allow
chown root:root /etc/cron.allow /etc/at.allow

echo "5.2.1 - Ensure permissions on /etc/ssh/sshd_config are configured"
chown root:root /etc/ssh/sshd_config
chmod 0600 /etc/ssh/sshd_config

echo "5.2.2, 5.2.3, 5.2.4, 5.2.5, 5.2.6, 5.2.7, 5.2.8, 5.2.9, 5.2.10, 5.2.11"
echo "5.2.12, 5.2.13, 5.2.14, 5.2.15"
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

echo "5.3.1 - Ensure password creation requirements are configured"
echo "5.3.2 - Ensure lockout for failed password attempts is configured"
echo "5.3.3 - Ensure password reuse is limited"
echo "5.3.4 - Ensure password hashing algorithm is SHA-512"
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
cat > /etc/pam.d/system-auth << PAMSYSCONFIG
auth        required                   pam_env.so
auth        required                   pam_faildelay.so delay=2000000
auth        required                   pam_faillock.so preauth audit silent deny=10 unlock_time=900
auth        sufficient                 pam_unix.so nullok try_first_pass
auth        sufficient                 pam_faillock.so authsucc audit deny=10 unlock_time=900
auth        requisite                  pam_succeed_if.so uid >= 500 quiet_success
auth        required                   pam_deny.so
auth        [success=1 default=bad]    pam_unix.so
auth        [default=die]              pam_faillock.so authfail audit deny=10 unlock_time=900

account     required                   pam_unix.so
account     sufficient                 pam_localuser.so
account     sufficient                 pam_succeed_if.so uid < 500 quiet
account     required                   pam_permit.so

password    requisite                  pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
password    sufficient                 pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=5
password    required                   pam_deny.so

session     optional                   pam_keyinit.so revoke
session     required                   pam_limits.so
-session    optional                   pam_systemd.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required                   pam_unix.so
PAMSYSCONFIG


echo "5.4.1.1 Ensure password expiration is 365 days or less"
# Whilst no users will be logging on to this system, our policy is 90 days for regular users and 365 for machine users
# Refs: https://git.ucd.gpn.gov.uk/dip/aws-common-infrastructure/wiki/Access-Management-Policy#regular-users
#       https://git.ucd.gpn.gov.uk/dip/aws-common-infrastructure/wiki/Access-Management-Policy#machine-accounts
sed -i 's/^PASS_MAX_DAYS.*$/PASS_MAX_DAYS 90/' /etc/login.defs

echo "5.4.1.2 - Ensure minimum days between password changes is 7 or more"
sed -i 's/^PASS_MIN_DAYS.*$/PASS_MIN_DAYS 7/' /etc/login.defs

echo "5.4.1.3 - Ensure password expiration warning days is 7 or more"
sed -i 's/^PASS_WARN_AGE.*$/PASS_WARN_AGE 7/' /etc/login.defs

echo "5.4.1.4 - Ensure inactive password lock is 30 days or less"
useradd -D -f 30

# echo "5.4.1.5 - Ensure all users last password change date is in the past"
# Exemption - we have no users that we configure with passwords

echo "5.4.2 - Ensure system accounts are non-login"
# No users in AL1 have this, CWA adds it later but we have dealt with this upstream

echo "5.4.3 - Ensure default group for the root account is GID 0"
usermod -g 0 root

echo "5.4.4 - Ensure default user umask is 027 or more restrictive"
sed -i 's/^.*umask 0.*$/umask 027/' /etc/bashrc
sed -i 's/^.*umask 0.*$/umask 027/' /etc/profile
sed -i 's/^.*umask 0.*$/umask 027/' /etc/profile.d/*.sh

echo "5.4.5 - Ensure default user shell timeout is 900 seconds or less"
echo 'TMOUT=600' >> /etc/bashrc
echo 'TMOUT=600' >> /etc/profile

echo "5.5 - Ensure access to the su command is restricted"
sed -i '/#auth.*required.*pam_wheel.so/s/^# *//' /etc/pam.d/su



echo "6.1.1 - Audit system file permissions"
# Exemption - we are not auditing all system files, unscored

echo "6.1.2 - Ensure permissions on /etc/passwd are configured"
chown root:root /etc/passwd
chmod 644 /etc/passwd

echo "6.1.3 - Ensure permissions on /etc/shadow are configured"
chown root:root /etc/shadow
chmod 000 /etc/shadow

echo "6.1.4 - Ensure permissions on /etc/group are configured"
chown root:root /etc/group
chmod 644 /etc/group

echo "6.1.5 - Ensure permissions on /etc/gshadow are configured"
chown root:root /etc/gshadow
chmod 000 /etc/gshadow

echo "6.1.6 - Ensure permissions on /etc/passwd-are configured"
chown root:root /etc/passwd-
chmod u-x,go-wx /etc/passwd-

echo "6.1.7 - Ensure permissions on /etc/shadow-are configured"
chown root:root /etc/shadow-
chmod 000 /etc/shadow-

echo "6.1.8 - Ensure permissions on /etc/group-are configured"
chown root:root /etc/group-
chmod u-x,go-wx /etc/group-

echo "6.1.9 - Ensure permissions on /etc/gshadow-are configured "
chown root:root /etc/gshadow-
chmod 000 /etc/gshadow-

echo "6.1.10 - Ensure no world writable files exist"
echo "Expect: no output"
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type f -perm -0002

echo "6.1.11 - Ensure no unowned files or directories exist"
echo "Expect: no output"
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nouser

echo "6.1.12 - Ensure no ungrouped files or directories exist"
echo "Expect: no output"
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nogroup

echo "6.1.13 - Audit SUID executables"
# Exemption - we are not auditing all system files, unscored

echo "6.1.14 - Audit SGID executables"
# Exemption - we are not auditing all system files, unscored



echo "6.2.1 - Ensure password fields are not empty"
echo "Expect: no output"
cat /etc/shadow | awk -F: '($2 == "" ) { print $1 " does not have a password "}'

echo "6.2.2 - Ensure no legacy '+' entries exist in /etc/passwd"
echo "Expect: no output"
grep '^\+:' /etc/passwd

echo "6.2.3 - Ensure no legacy '+' entries exist in /etc/shadow"
echo "Expect: no output"
grep '^\+:' /etc/shadow

echo "6.2.4 Ensure no legacy '+' entries exist in /etc/group"
echo "Expect: no output"
grep '^\+:' /etc/group

echo "6.2.5 - Ensure root is the only UID 0 account"
echo "Expect: root"
cat /etc/passwd | awk -F: '($3 == 0) { print $1 }'

echo "6.2.6 - Ensure root PATH Integrity"
echo "Expect: no output"
if [ " `echo $PATH | grep ::` " != "" ]; then
  echo "Empty Directory in PATH (::)"
fi
if["`echo$PATH|grep:$`" !=""];then 
  echo "Trailing : in PATH"
fi
p= `echo $PATH | sed -e 's/::/:/' -e 's/:$//' -e 's/:/ /g'` 
set -- $p
while [ "$1" != "" ]; do
  if [ "$1" = "." ]; then
    echo "PATH contains ."
    shift
    continue
  fi
  if [ -d $1 ]; then
    dirperm= `ls -ldH $1 | cut -f1 -d" "`
    if [ `echo $dirperm | cut -c6`  != "-" ]; then
      echo "Group Write permission set on directory $1"
    fi
    if [ `echo $dirperm | cut -c9` != "-" ]; then
      echo "Other Write permission set on directory $1"
    fi
    dirown= `ls -ldH $1 | awk '{print $3}'`
    if [ "$dirown" != "root" ] ; then
      echo $1 is not owned by root
    fi
  else
    echo $1 is not a directory
  fi
  shift
done


echo "6.2.7 - Ensure all users' home directories exist"
echo "Expect: all users to have home folders"
cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }'


echo "6.2.8 - Ensure users' home directories permissions are 750 or more restrictive"
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


echo "6.2.9 - Ensure users own their home directories"
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


echo "6.2.10 - Ensure users' dot files are not group or world writable"
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


echo "6.2.11 - Ensure no users have .forward files"
echo "Expect: no output"
cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
  if [ ! -d "$dir" ]; then
    echo "The home directory ($dir) of user $user does not exist."
  else
  if [ ! -h "$dir/.forward" -a -f "$dir/.forward" ]; then
    echo ".forward file $dir/.forward exists" fi
  fi
done


echo "6.2.12 - Ensure no users have .netrc files"
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


echo "6.2.13 - Ensure users' .netrc Files are not group or world accessible"
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


echo "6.2.14 - Ensure no users have .rhosts files"
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


echo "6.2.15 - Ensure all groups in /etc/passwd exist in /etc/group"
echo "Expect: no output"
for i in $(cut -s -d: -f4 /etc/passwd | sort -u ); do
  grep -q -P "^.*?:[^:]*:$i:" /etc/group
  if [ $? -ne 0 ]; then
   echo "Group $i is referenced by /etc/passwd but does not exist in /etc/group"
  fi
done


echo "6.2.16 - Ensure no duplicate UIDs exist"
echo "Expect: no output"
cat /etc/passwd | cut -f3 -d":" | sort -n | uniq -c | while read x ; do
  [ -z "${x}" ] && break
  set - $x
  if [ $1 -gt 1 ]; then
    users= `awk -F: '($3 == n) { print $1 }' n=$2 /etc/passwd | xargs`
    echo "Duplicate UID ($2): ${users}"
  fi
done


echo "6.2.17 - Ensure no duplicate GIDs exist"
cat /etc/group | cut -f3 -d":" | sort -n | uniq -c | while read x ; do
  [ -z "${x}" ] && break
  set - $x
  if [ $1 -gt 1 ]; then
    groups= `awk -F: '($3 == n) { print $1 }' n=$2 /etc/group | xargs`
    echo "Duplicate GID ($2): ${groups}"
  fi
done


echo "6.2.18 - Ensure no duplicate user names exist"
echo "Expect: no output"
cat /etc/passwd | cut -f1 -d":" | sort -n | uniq -c | while read x ; do
  [ -z "${x}" ] && break
  set - $x
  if [ $1 -gt 1 ]; then
    uids= `awk -F: '($1 == n) { print $3 }' n=$2 /etc/passwd | xargs`
    echo "Duplicate User Name ($2): ${uids}"
  fi
done


echo "6.2.19 - Ensure no duplicate group names exist"
echo "Expect: no output"
cat /etc/group | cut -f1 -d":" | sort -n | uniq -c | while read x ; do
  [ -z "${x}" ] && break
  set - $x
  if [ $1 -gt 1 ]; then
    gids= `gawk -F: '($1 == n) { print $3 }' n=$2 /etc/group | xargs`
    echo "Duplicate Group Name ($2): ${gids}"
  fi
done
