import openstack
import netaddr
import sys
import os

hostname_tmpl="target%03d%03d%03d%03d"
dnsmasq_file='roles/paddles_nodes/files/etc/dnsmasq.d/teuthology'
postgre_file='roles/paddles_nodes/files/populate_nodes.psql'

def list_ipv4_networks(name, ipv=4):
    c = openstack.connect()
    net = c.network.find_network(name)
    if not net:
        print("No networks found with name %s" % name)
        return
    print("Found net '%s', id: %s" % (net.name, net.id))
    addr = []
    for i in (x for x in c.network.subnets() 
                                    if x.ip_version == ipv 
                                    and x.network_id == net.id):
        print(i.name, i.id, i.ip_version, i.cidr)
        print(i.cidr)
        addr += [str(x) for x in netaddr.IPNetwork(i.cidr)]
    for i in addr:
        yield i

#for i in ['fixed', 'sesci', 'Ext-Net']:
def host_names_and_ips(net, max=None):
    for ip in list(list_ipv4_networks(net))[0:max]:
        h = hostname_tmpl % tuple(int(o) for o in ip.split('.'))
        yield (h, ip) 

def gen_postgres_insert(iter_names_and_ips,
            lab_domain='teuthology', 
            machine_type='openstack'):
    yield "begin transaction;"
    yield "insert into nodes (name,machine_type,is_vm,locked,up) values "
    prev_name = None
    def value(name='host'):
        return "('{name}.{labdomain}', '{type}', TRUE, FALSE, TRUE)"\
                .format(name=name, labdomain='teuthology', type=machine_type)
    for hostname, ip in iter_names_and_ips:
        #yield (
        #    "insert into nodes (name,machine_type,is_vm,locked,up)"
        #    " values ('{name}.{labdomain}', '{type}', TRUE, FALSE, TRUE);"
        #    .format(name=hostname, labdomain='teuthology', type=machine_type)
        #)
        if prev_name:
            yield (value(prev_name) + ",")
        prev_name = hostname
        
    yield (value(prev_name) + ";")
    yield "commit transaction"

def dnsmasq_lines(iter_names_and_ips):
    for n, i in iter_names_and_ips:
        yield "host-record=%s,%s" % (n,i)

def example():
    for i in ['fixed', 'sesci', 'Ext-Net']:
        for x,y in host_names_and_ips(i):
            print("%s %s" % (x, y))
def write_file(fileobj, gen):
    for i in gen:
        fileobj.write("%s\n" % i)

def write_path(path, gen):
    p=os.path.dirname(os.path.abspath(path))
    print('writing file %s' % path)
    if not os.path.exists(p):
        os.makedirs(p)
    with open(path, 'w') as f:
        write_file(f, gen)

def make_ansible_files(network, machine='openstack'):
    names_ips=list(host_names_and_ips(network))
    write_path(dnsmasq_file, dnsmasq_lines(names_ips))
    write_path(postgre_file, gen_postgres_insert(names_ips, machine_type=machine))


cloud='ecp'
if len(sys.argv) > 1:
    cloud = sys.argv[1]
net_map = {
        'ecp': 'sesci',
        'ecn': 'fixed',
        'ovh': 'Ext-Net',
        'bhs': 'Ext-Net',
        'gra': 'Ext-Net',
        'sbg': 'Ext-Net',
        'waw': 'Ext-Net',
        'de': 'Ext-Net',
        'uk': 'Ext-Net',
        'bhs3': 'Ext-Net',
        'sbg5': 'Ext-Net',
        'gra5': 'Ext-Net',
        'waw1': 'Ext-Net',
        'de1': 'Ext-Net',
        'uk1': 'Ext-Net',
        }
#make_ansible_files('Ext-Net', 'ovh')
make_ansible_files(net_map[cloud], 'openstack')

