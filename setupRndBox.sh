#!/bin/bash
#
# set up an RnD box so it can be used for performance testing
# Specifically:
# - disable auto-puppet
# - wipe ALL iptables rules
# - add all rnd boxes to /etc/hosts
# - make sure 0mq is installed in /usr/lib
# 
# then, if we're a test* box
# - make sure /opt/beSolr/beSolr has the correct ZK_ARGS, LIB_ARGS, and Xmx values
# - ensure Loggly.properties has the correct splitter.locate.hosts value
#
# otherwise, if we're a hammer* box
# - make sure 

# first, remove the puppet cron job so our changes don't get undone
#
if [ -e /etc/cron.d/puppet ]
then
    echo `date` ": INFO : Removing puppet cron file"
    sudo rm /etc/cron.d/puppet
else
    echo `date` ": WARN : Puppet cron file already removed"
fi

# next, wipe all iptables rules. We'll rely on AWS security to keep things safe
#
# note: this is a bit more dangerous in a colo.
echo `date` ": INFO : Clearing iptables rules"
sudo iptables -F INPUT
sudo iptables -F OUTPUT


# first, make sure we have the internal IPs of all of the other boxes in the cluster in /etc/hosts
#
# this list was generated using the following command...
#     cat /etc/truth.json|  awk '/"[a-z0-9]+"/{h = $1}/private/{print $2,h}'| sed -e 's/"//g' -e 's/,//' -e 's/://' | sort -k 2 | grep -v gsd3 | grep -v niz | awk '{print $1 "\t" $2 " " $2 ".rnd.loggly.net"}'
#
# but we can't use that on a box were puppet is having problems, so its a here doc for now (sigh)
#

if grep autogenerated /etc/hosts > /dev/null 2>&1
then
    echo `date` ": WARN : Skipping /etc/hosts changes - already done"
else
    NOW=`date`
    cat <<EOF | grep -v $HOSTNAME > /tmp/allHosts

# All hosts in RnD cluster - autogenerated by $0 on $NOW
#

10.218.37.183	hammer1 hammer1.rnd.loggly.net
10.102.25.207	hammer2 hammer2.rnd.loggly.net
10.218.59.159	hammer3 hammer3.rnd.loggly.net
10.218.63.167	hammer4 hammer4.rnd.loggly.net
10.13.49.127	hammer5 hammer5.rnd.loggly.net
10.218.19.191	hammer6 hammer6.rnd.loggly.net
10.218.31.167	hammer7 hammer7.rnd.loggly.net
10.102.55.116	hammer8 hammer8.rnd.loggly.net

10.16.41.70	test05 test05.rnd.loggly.net
10.16.33.236	test06 test06.rnd.loggly.net
10.156.162.78	test07 test07.rnd.loggly.net
10.156.162.43	test08 test08.rnd.loggly.net
10.76.43.99	test09 test09.rnd.loggly.net
10.78.238.154	test10 test10.rnd.loggly.net
10.100.177.146	test11 test11.rnd.loggly.net
10.32.194.96	test12 test12.rnd.loggly.net

# All hosts in colo2

10.0.36.213  solr15-01 solr15-01.colo2.loggly.net
10.0.36.214  solr15-02 solr15-02.colo2.loggly.net

EOF

    cat /etc/hosts /tmp/allHosts > /tmp/etcHosts
    echo `date` ": INFO : Setting up /etc/hosts"
    sudo mv /etc/hosts /etc/hosts.`date +%Y%m%d.%H%M%S.%N`
    sudo mv /tmp/etcHosts /etc/hosts
fi

echo `date` ": INFO : Downloading tarballs"
cd /opt
for  filename  in beHammer beSolr hammer.test.opt solr.test.opt zk.version-2 zmq.prod.usr.lib zookeeper.test.version-2 zoto.log
do
    fullname=$filename.tgz
    if [ -e /opt/$fullname ]
    then
        echo `date` ": INFO: $fullname already exists"
    else
        echo `data` ": INFO: Downloading $fullname"
        sudo wget http://repo.loggly.org/repo/pool/files/$fullname
    fi
done


cd /usr/lib
if [ -e ./libjzmq.a ]
then
    echo `date` ": WARN : Skipping install of 0mq in /usr/lib - already done"
else
    echo `date` ": INFO : Installing 0mq in /usr/lib"
    sudo tar zxvf /opt/zmq.prod.usr.lib.tgz
fi

setupSolr () {
    hName="$1"
    sName="$2"
	echo `date` ": INFO : Setting up test box $sName to run solr using $hName"

	echo `date` ": INFO : Shutting down loggly-solrserver"
	supervisorctl stop loggly-solrserver
	
	echo `date` ": INFO : untar'ing beSolr into /opt"
	cd /opt
	sudo rm -rf beSolr
	sudo tar zxvf /opt/solr.test.opt.tgz

	sudo cp /opt/beSolr/dist/solr/solr.xml.Bootstrap /opt/beSolr/dist/solr/solr.xml
	sudo chmod ugo+w /opt/beSolr/dist/solr/solr.xml

	echo `date` ": INFO : Fixing Loggly.properties for beSolr"
	cd /opt/beSolr/dist/etc
	grep -v hosts Loggly.properties | grep -v 'index.shard.minutes' | grep -v 'delay.addindexer.millis' | grep -v 'index.cores.percent' | grep -v 'index.queue.maxsize' | grep -v 's3.enabled' > /tmp/newProps
	cat <<EOF >> /tmp/newProps

# ****************************** T E S T   S T A R T ******************************
#
# Solr test configs - autogenerated by $0 on $NOW
#

# hosts needed by this solr in RnD cluster 
#
hosts.splitter=$hName
hosts.solr=$sName

# make sure we're using prod values for shard sizes
#
index.shard.minutes=5,30,240,1440,10080

# Let Indexers spin up quicker (one new indexer every 2 seconds)
#
delay.addindexer.millis=5000

# use every available core for indexing (yep, this is dangerous)
#
index.cores.percent=100

# Use a truly monstrous event queue in the indexer so we can slam
# events into solr faster than we can index without worrying too much
# about blowing up
#
index.queue.maxsize=100000000

# Don't use S3
#
s3.enabled=false


# ****************************** T E S T   E N D ******************************

EOF
	sudo cp /tmp/newProps Loggly.properties

	echo `date` ": INFO : Fixing /opt/beSolr/beSolr startup script"
	cd /opt/beSolr
	mem=`grep MemTotal /proc/meminfo  | awk '{print int($2/2)}'`
	sed -e "s/u100401/$hName/" -e "s/Xmx1000m/Xmx${mem}k/" -e "s/jon/rnd/" -e "s/usr\/local\/lib/usr\/lib/" < beSolr > /tmp/newBeSolr
	sudo cp /tmp/newBeSolr beSolr
	sudo chmod ugo+x beSolr

	echo `date` ": INFO : Creating bounceSolr script"
        cat <<EOF > /tmp/bounceSolr
#!/bin/sh
#
# bounce Solr and clean up log files
#
cd /opt/beSolr/dist
../beSolr stop
sleep 1
sudo kill -9 \`ps -ef | grep beSolr | grep -v bounceSolr | awk '{print \$2}'\`
echo "STOPPED"
mkdir history
fgrep IdxM logs/* > run.ended.`date +%Y%m%d.%H%M%S`
sleep 5
sudo rm beSolr.pid logs/*
sudo ../beSolr start
tail -F logs/beSolr.log logs/beSolr.log
EOF

        sudo cp /tmp/bounceSolr /opt/beSolr/bounceSolr
        sudo chmod ugo+x /opt/beSolr/bounceSolr
	
	echo `date` ": INFO : Setting up shards on /mnt"
	sudo mkdir -p /mnt/test/shards
	sudo chmod ugo+rwx /mnt/test/shards
	sudo rm -rf /opt/beSolr/dist/solr/shards
	sudo ln -s /mnt/test/shards /opt/beSolr/dist/solr/shards
}
# end of setupSolr

setupHammer() {
    hName="$1"
    sName="$2"
	echo `date` ": INFO : Setting up hammer box $hName for zookeeper, collector, splitter and hammer for use by $sName"
	
	echo `date` ": INFO : Shutting down collector, splitter, tapper, and zookeeper"
	supervisorctl stop becollector-loggly besplitter-loggly
	sudo /etc/init.d/hadoop-zookeeper-server stop


	echo `date` ": INFO : untar'ing collector, splitter hammer into /opt"
	cd /opt
	sudo tar zxvf /opt/hammer.test.opt.tgz

	echo `date` ": INFO : Fixing Loggly.properties for collector"
	cd /opt/beCollector/dist/etc
	grep -v hosts Loggly.properties | grep -v 's3.enabled' > /tmp/newProps
	cat <<EOF >> /tmp/newProps

# ****************************** T E S T   S T A R T ******************************
#
# Collector test configs - autogenerated by $0 on $NOW
#

# hosts needed by this collector in RnD cluster
#
hosts.splitter=localhost
hosts.solr=$sName
splitter.locate.hosts=$sName

# Don't use S3 when testing
#
s3.enabled=false

# ****************************** T E S T   E N D ******************************

EOF
	sudo cp /tmp/newProps Loggly.properties

        echo `date` ": INFO : Fixing beCollector script"
	cd /opt/beCollector
	sed -e 's/usr\/local\/lib/usr\/lib/' < beCollector > /tmp/newBeCollector
	sudo cp /tmp/newBeCollector beCollector

        echo `date` ": INFO : Creating bounceCollector script"
        cat <<EOF > /tmp/bounceCollector
#!/bin/sh
#
# bounce collector and clean up log files
#
cd /opt/beCollector/dist
../beCollector stop
sleep 1
sudo kill -9 \`ps -ef | grep beCollector | grep -v bounceCollector | awk '{print \$2}'\`
echo "STOPPED"
sleep 5
sudo rm beCollector.pid logs/*
sudo ../beCollector start
tail -F logs/beCollector.log logs/beCollector_console.log
EOF

        sudo cp /tmp/bounceCollector /opt/beCollector/bounceCollector
        sudo chmod ugo+x /opt/beCollector/bounceCollector
        ls -l /opt/beCollector


	echo `date` ": INFO : Fixing Loggly.properties for splitter"
	cd /opt/beSplitter/dist/etc
	grep -v hosts Loggly.properties > /tmp/newProps
	cat <<EOF >> /tmp/newProps

# ****************************** T E S T   S T A R T ******************************
#
# Splitter test configs - autogenerated by $0 on $NOW
#

# hosts needed by this splitter in RnD cluster - autogenerated by $0 on $NOW
#
hosts.solr=$sName
splitter.locate.hosts=$sName

# ****************************** T E S T   E N D ******************************
EOF
	sudo cp /tmp/newProps Loggly.properties

        echo `date` ": INFO : Fixing beSplitter script"
	cd /opt/beSplitter
	sed -e 's/usr\/local\/lib/usr\/lib/' < beSplitter > /tmp/newBeSplitter
	sudo cp /tmp/newBeSplitter beSplitter

        echo `date` ": INFO : Creating bounceSplitter script"
        cat <<EOF > /tmp/bounceSplitter
#!/bin/sh
#
# bounce splitter and clean up log files
#
cd /opt/beSplitter/dist
../beSplitter stop
sleep 1
sudo kill -9 \`ps -ef | grep beSplitter | grep -v bounceSplitter | awk '{print \$2}'\`
echo "STOPPED"
sleep 5
sudo rm beSplitter.pid logs/*
sudo ../beSplitter start
tail -F logs/beSplitter.log logs/beSplitter_console.log
EOF

        sudo cp /tmp/bounceSplitter /opt/beSplitter/bounceSplitter
	sudo chmod ugo+x /opt/beSplitter/bounceSplitter
	
	echo `date` ": INFO : Fixing zookeeper to run in standalone mode"
	grep -v 3888 /etc/zookeeper/zoo.cfg | grep -v ensemble > /tmp/newZooCfg
	sudo cp /tmp/newZooCfg /etc/zookeeper/zoo.cfg
	cd /mnt/zookeeper/data/
	sudo rm -rf version-2
	sudo tar zxvf /opt/zookeeper.test.version-2.tgz
	sudo rm /mnt/log/zookeeper/zoo*

	echo `date` ": INFO : Starting zookeeper in standalone mode"
	sudo /etc/init.d/hadoop-zookeeper-server start

}

case $HOSTNAME in

    # ==================== Set up a Solr box ====================
    test*)
	tNum=`echo $HOSTNAME | cut -c5,6`
        if [ "$tNum" == "08" -o "$tNum" == "09" ] 
	then
	    tNum=`echo $HOSTNAME | cut -c6`
	fi
	hNum=$((tNum-4))
    hName="hammer$hNum"
    sName="test$tNum"
    setupSolr "$hName" "$sName"
	
	;;

    solr15-02*)
    setupSolr solr15-01 $HOSTNAME
    ;;

    # ==================== Set up a Collector, Splitter, Hammer, ZooKeeper box ====================

    hammer*)
	hNum=`echo $HOSTNAME | cut -c7`
	tNum=$((hNum+4))
	if [ $tNum -lt 10 ]
	then
	    tNum="0${tNum}"
	fi

    hName="hammer$hNum"
    sName="test$tNum"

    setupHammer "$hName" "$sName"
    ;;

    solr15-01*)
    setupHammer solr15-01 solr15-02
	


	;;
esac
