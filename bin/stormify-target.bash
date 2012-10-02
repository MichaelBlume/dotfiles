exec 1>/tmp/stormify-log
sudo apt-get update
sudo apt-get install -y openjdk-6-jdk build-essential libtool autoconf automake git uuid-dev pkg-config unzip
mkdir workspace
cd workspace
wget http://download.zeromq.org/zeromq-2.1.7.tar.gz
tar -xzf zeromq-2.1.7.tar.gz
cd zeromq-2.1.7
./configure
make
sudo make install
cd ..
git clone https://github.com/nathanmarz/jzmq.git
cd jzmq
./autogen.sh
JAVA_HOME=/usr/lib/jvm/java-6-openjdk/ ./configure
make
sudo make install
cd ..
wget https://github.com/downloads/nathanmarz/storm/storm-0.8.1.zip
unzip storm-0.8.1.zip
if [ $ZOOKEEPER ]
  then

  wget http://apache.petsads.us/incubator/kafka/kafka-0.7.1-incubating/kafka-0.7.1-incubating-src.tgz
  tar xvfz kafka-0.7.1-incubating-src.tgz

  cd kafka-0.7.1-incubating
  ./sbt update
  ./sbt package

  echo "starting zookeeper process"
  screen -d -m -S zookeeper bin/zookeeper-server-start.sh config/zookeeper.properties
  cd ..
fi

cd storm-0.8.1
cp $HOME/storm.yaml conf/storm.yaml
if [ $NIMBUS ]
  then
  echo "starting nimbus processes"
  screen -d -m -S nimbus bash -c "while true; do bin/storm nimbus; done"
  screen -d -m -S ui bash -c "while true; do bin/storm ui; done"
fi

if [ $SUPERVISOR ]
  then
  echo "starting supervisor process"
  screen -d -m -S supervisor bash -c "while true; do bin/storm supervisor; done"
fi

echo "finished stormifying box"
