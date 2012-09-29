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
cd storm-0.8.1
cp $HOME/storm.yaml conf/storm.yaml
