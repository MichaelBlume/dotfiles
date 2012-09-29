import os
import pwd
from threading import Thread

import envoy

run_zookeeper = ';'.join("""
wget http://apache.petsads.us/incubator/kafka/kafka-0.7.1-incubating/kafka-0.7.1-incubating-src.tgz
tar xvfz kafka-0.7.1-incubating-src.tgz
cd kafka-0.7.1-incubating
./sbt update
./sbt package
screen -d -m "bin/zookeeper-server-start.sh config/zookeeper.properties"
""".split('\n'))

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

    target_script = os.path.join(os.path.dirname(__file__), 'stormify-target')

    run_zk = ext_zookeeper_host is None
    threads = [Thread(target=stormify_host,
                      args=(host, n, user, target_script, run_zk))
               for n, host in enumerate(hosts)]
    for t in threads: t.run()
    for t in threads: t.join()

def do_forever(full_host, storm_command):
    envoy.run("""ssh %s 'cd workspace/storm-0.8.1/;
            screen -d -m "while true; do bin/storm %s; done"' """ %
            (full_host, storm_command))

def stormify_host(host, number, user, target_script, run_zk):
    full_host = "%s@%s" % (user, host)
    print 'running scp'
    envoy.run("scp %s %s:" % (target_script, full_host))
    print 'scp done! running stormify script'
    envoy.run('ssh %s "bash stormify-target > stormsetuplog"' % full_host)
    print 'moving config file into place'
    envoy.run("scp storm_conf.tmp %s:workspace/storm-0.8.1/config/storm.yaml" %
            full_host)
    print 'setting up daemons'
    if number == 0:
        # we're setting up a nimbus
        if run_zk:
            envoy.run(" ssh %s '%s'" % (full_host, run_zookeeper))

        do_forever(full_host, 'nimbus')
        do_forever(full_host, 'ui')
    else:
        do_forever(full_host, 'supervisor')
