import os
import pwd

import envoy

def setup_storm_cluster(hosts, ext_zookeeper_host=None, user=None):
    if user is None:
        user = pwd.getpwuid(os.getuid())[0]
    zookeeper_host = ext_zookeeper_host or hosts[0]
    storm_config = """

storm.zookeeper.servers:
    - "%s"

nimbus.host: "%s"

storm.local.dir: /home/%s/storm

    """ % (zookeeper_host, hosts[0], user)
    with open("storm_conf.tmp", "w") as f:
        f.write(storm_config)

    target_script = os.path.join(os.path.dirname(__file__),
            'stormify-target.bash')

    run_zk = ext_zookeeper_host is None
    for n, host in enumerate(hosts):
        stormify_host(host, n, user, target_script, run_zk)

def stormify_host(host, number, user, target_script, run_zk):
    full_host = "%s@%s" % (user, host)

    flags = ''
    if number == 0:
        # we're setting up a nimbus
        if run_zk:
            flags = 'ZOOKEEPER=1 ' + flags

        flags = 'NIMBUS=1 ' + flags
    else:
        flags = 'SUPERVISOR=1 ' + flags

    print 'scp-ing stormify script'
    envoy.run("scp %s %s:" % (target_script, full_host))
    print 'scp-ing storm config'
    envoy.run("scp storm_conf.tmp %s:storm.yaml" %
            full_host)
    print 'scp done! running stormify script'
    cmd = ('''ssh %s "%sscreen -d -m bash stormify-target.bash"'''
            % (full_host, flags))
    print cmd
    envoy.run(cmd)
