## Deploy teuthology instance


### Setup environment

Install terraform from the page: https://www.terraform.io/downloads.html

For example, if you are on SUSE based distro you could do next:

```bash
curl -O https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
unzip terraform_0.11.13_linux_amd64.zip -d ~/bin/
```

Setup virtual environment with python dependencies:

```bash
virtualenv v
. v/bin/activate
pip install --upgrade pip
pip install ansible python-openstackclient
```

Clone ceph-cm-ansible of required fork and branch
```bash
git clone https://github.com/suse/ceph-cm-ansible -b suse
```

### Configure

Copy stub yaml files to configs
```bash
cp teuthology-vars.yml.orig teuthology-vars.yml
cp conf/teuthology.cfg.orig conf/teuthology.cfg
cp libcloud/ovh.cfg.orig libcloud/ovh.cfg
```
and modify correspondingly openstack credentials for libcloud
and tweak teuthology config

Add _ovh_, _sbg_, _nbg_, etc. data to `~/.config/openstack/clouds.yaml`

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

