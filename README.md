## Deploy teuthology instance


### Install prerequisites

Install jq binary

```bash
zypper install -f jq
```

Install terraform from the page: https://www.terraform.io/downloads.html

For example, if you are on SUSE based distro you could do next:

```bash
curl -O https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
unzip terraform_0.11.13_linux_amd64.zip -d ~/bin/
```

Get the source code and change directory into its root.

```bash
git clone https://github.com/SUSE/teuthology-deploy
cd teuthology-deploy
```

Setup virtual environment with python dependencies:

```bash
virtualenv v
. v/bin/activate
pip install --upgrade pip
pip install ansible==2.8.4 python-openstackclient
```

Clone ceph-cm-ansible of required fork and branch
```bash
git clone https://github.com/SUSE/ceph-cm-ansible -b suse
```
(Note: At moment of writing the SUSE ceph-cm-ansible is required to be used
in order to setup teuthology on openSUSE based distro since his corresponding
patches in 'suse' branch. The 'master' branch is supposed to be equivalent to
the upstream one.)

The user should have access to /usr/sbin/dnssec-keygen in order to make
keys for nameserver, for example it can be found in system package 'bind-utils'
in openSUSE distros.
```bash
sudo zypper in bind-utils
```

### Create deployment config

Copy stub yaml files to configs
```bash
cp teuthology-vars.yml.orig teuthology-vars.yml
cp conf/teuthology.cfg.orig conf/teuthology.cfg
cp libcloud/ovh.cfg.orig libcloud/ovh.cfg
```
and modify correspondingly openstack credentials for libcloud
and tweak teuthology config.

(As an option you can use --conf argument to point to presaved teuthology.cfg
explicitly.)

Your system should have 'cloud' based access to your openstack and
must have corresponding config to the once in 'terraform' directory.
So, add _ovh_, _sbg_, _nbg_, etc. data to `~/.config/openstack/clouds.yaml`.

### Deploy teuthology cluster

Deploy cluster with named and `nsupdate_web` setup on teuthology server in _ovh_.
```bash
OS_CLOUD=ovh ./deploy-teuthology --rebuild --ns
```
To have more than one cluster per region or project, specify unique name for the cluster:
```bash
OS_CLOUD=ovh ./deploy-teuthology --rebuild --ns --name $USER
```
If you need more workers and target machines, use corresponding arguments:
```bash
OS_CLOUD=ovh ./deploy-teuthology --rebuild --ns --workers 8 --targets 50
```

Cleanup cluster:

```bash
OS_CLOUD=ovh ./deploy-teuthology --cleanup
```

### Using several configs at once

Copy `conf/teuthology.cfg.orig` to something distrinct, for example, `conf/foo.cfg`.
Copy `teuthology-vars.yml.orig` to something specific, like `teuthology-foo.yml`.

And use `TEUTH_CONF` and `TEUTH_VARS` correspondingly:
```bash
export TEUTH_CONF=conf/foo.cfg
export TEUTH_VARS=teuthology-foo.yml
./deploy-teuthology --cloud ovh --ns --rebuild
```

