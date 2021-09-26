# Readme

An educational lab VM to learn about the 9.6 CVSS unauthenticated Remote Code Execution (RCE) vulnerability in Open Management Infrastructure software (CVE-2021-38647).

Disclosure (original research): https://www.wiz.io/blog/omigod-critical-vulnerabilities-in-omi-azure

OMI source code: https://github.com/microsoft/omi

news:
* https://nakedsecurity.sophos.com/2021/09/16/omigod-an-exploitable-hole-in-microsoft-open-source-code/
* https://www.zdnet.com/article/omigod-azure-users-running-linux-vms-need-to-update-now/
* https://threatpost.com/microsoft-patch-tuesday-exploited-windows-zero-day/169459/

Write up:
* https://censys.io/blog/understanding-the-impact-of-omigod-cve-2021-38647/

Read some of the above before proceeding.

## Setup

* Install [Vagrant](https://www.vagrantup.com/)
* Install a [supported hypervisor](https://app.vagrantup.com/generic/boxes/ubuntu2004)

```shell
git clone https://github.com/craig-m-unsw/omigod-lab.git
cd omigod-lab
vagrant up
vagrant ssh
```

This will setup Ubuntu 20.04 (Focal Fossa). Thanks [Roboxes](https://roboxes.org/) for the Vagrant box.

Installed by Ansible `playbook.yml`:

* omi-1.6.8-0.ssl_110.ulinux.x64.deb - `sha256:2e0813ee3f2a71028f071d9933ca2f336faaaf9b6126d5f1767ffcbc7e803279`
* scx-1.6.8-1.ssl_110.ulinux.x64.deb - `sha256:1cba16e3b307177cbe15bd3fd8a2a87ab8d638846988202be8a17981b5e900c9`

Don't put this VM on the internet :-)

## Exploiting

Thanks to vagrant a port forward on localhost:5986 to 5986 in the VM will be open after bring the box up. We have a lab VM to test with now.

#### CVE-2021-38647

We just need to send this xml request to a vulnerable OMI server:

```shell
cd /vagrant
. send-payload.sh
```

You should see the output to `printenv` command in `<p:StdOut>`.

If you change the command in `payload.xml` to be `id` you can see `uid=0(root) gid=0(root) groups=0(root)` outputs.

😬😬😬

Other public exploit code:

* https://github.com/AlteredSecurity/CVE-2021-38647
* https://github.com/horizon3ai/CVE-2021-38647
* https://github.com/Immersive-Labs-Sec/cve-2021-38647

## Using omi

The Getting Started doco from MS:
https://github.com/microsoft/omi/blob/master/Unix/doc/omi/omi.pdf

## Detect

Inside the VM auditd is installed.

Log all command exec:

```shell
sudo auditctl -a exit,always -F arch=b32 -S execve -k execve
sudo auditctl -a exit,always -F arch=b64 -S execve -k execve
```

```shell
sudo tail -f /var/log/audit/audit.log
```

The output from sending a command:

```
type=SYSCALL msg=audit(1631977306.937:107): arch=c000003e syscall=59 success=yes exit=0 a0=7f906c002570 a1=7f906c001330 a2=7fffe5148108 a3=7f90751453f0 items=2 ppid=8552 pid=9974 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="sh" exe="/usr/bin/dash" key="execve"
type=EXECVE msg=audit(1631977306.937:107): argc=3 a0="/bin/sh" a1="-c" a2="whoami"
type=CWD msg=audit(1631977306.937:107): cwd="/var/opt/microsoft/scx/tmp"
type=PATH msg=audit(1631977306.937:107): item=0 name="/bin/sh" inode=5374016 dev=08:03 mode=0100755 ouid=0 ogid=0 rdev=00:00 nametype=NORMAL cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0 cap_frootid=0
type=PATH msg=audit(1631977306.937:107): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=5377053 dev=08:03 mode=0100755 ouid=0 ogid=0 rdev=00:00 nametype=NORMAL cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0 cap_frootid=0
type=PROCTITLE msg=audit(1631977306.937:107): proctitle=2F62696E2F7368002D630077686F616D69
type=SYSCALL msg=audit(1631977306.937:108): arch=c000003e syscall=59 success=yes exit=0 a0=564c4e436b90 a1=564c4e436b38 a2=564c4e436b48 a3=7f5b83f28850 items=2 ppid=9974 pid=9975 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="whoami" exe="/usr/bin/whoami" key="execve"
type=EXECVE msg=audit(1631977306.937:108): argc=1 a0="whoami"
type=CWD msg=audit(1631977306.937:108): cwd="/var/opt/microsoft/scx/tmp"
type=PATH msg=audit(1631977306.937:108): item=0 name="/usr/bin/whoami" inode=5374366 dev=08:03 mode=0100755 ouid=0 ogid=0 rdev=00:00 nametype=NORMAL cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0 cap_frootid=0
type=PATH msg=audit(1631977306.937:108): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=5377053 dev=08:03 mode=0100755 ouid=0 ogid=0 rdev=00:00 nametype=NORMAL cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0 cap_frootid=0
type=PROCTITLE msg=audit(1631977306.937:108): proctitle="whoami"
```

Someone has run "whoami".

Microsoft note this in the blog post "Additional Guidance Regarding OMI Vulnerabilities within Azure VM Management Extensions" on detection:

https://msrc-blog.microsoft.com/2021/09/16/additional-guidance-regarding-omi-vulnerabilities-within-azure-vm-management-extensions/
