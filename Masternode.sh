#!/bin/bash

clear

# Set these to change the version of Arktur to install
TARBALLURL="https://github.com/Arkturdev/Arktur-coin/releases/download/1.1.0/Arktur-1.1-Ubuntu-daemon.tgz"
TARBALLNAME="Arktur-1.1-Ubuntu-daemon.tgz"
ARTVERSION="1.1.0.0"

#!/bin/bash

# Check if we are root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root." 1>&2
   exit 1
fi

# Check if we have enough memory
if [[ `free -m | awk '/^Mem:/{print $2}'` -lt 850 ]]; then
  echo "This installation requires at least 1GB of RAM.";
  exit 1
fi

# Check if we have enough disk space
if [[ `df -k --output=avail / | tail -n1` -lt 10485760 ]]; then
  echo "This installation requires at least 10GB of free disk space.";
  exit 1
fi

# Install tools for dig and systemctl
echo "Preparing installation..."
apt-get install git dnsutils systemd -y > /dev/null 2>&1

# Check for systemd
systemctl --version >/dev/null 2>&1 || { echo "systemd is required. Are you using Ubuntu 16.04?"  >&2; exit 1; }

# CHARS is used for the loading animation further down.
CHARS="/-\|"

EXTERNALIP=`dig +short myip.opendns.com @resolver1.opendns.com`

clear

echo "

  ------- ARKTUR MASTERNODE INSTALLER v1 -------+
 

"

sleep 5

USER=art

adduser $USER --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password > /dev/null

echo "" && echo 'Added user "art"' && echo ""
sleep 1


USERHOME=`eval echo "~$USER"`


read -e -p "Enter Masternode Private Key (e.g. 7edfjLCUzGczZi3JQw8GHp434R9kNY33eFyMGeKRymkB56G4324h # THE KEY YOU GENERATED EARLIER) : " KEY



clear

# Generate random passwords
RPCUSER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
RPCPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# update packages and upgrade Ubuntu
echo "Installing dependencies..."
apt-get -qq update
apt-get -qq upgrade
apt-get -qq autoremove
apt-get -qq install wget htop unzip
apt-get -qq install build-essential && apt-get -qq install libtool libevent-pthreads-2.0-5 autotools-dev autoconf automake && apt-get -qq install libssl-dev && apt-get -qq install libboost-all-dev && apt-get -qq install software-properties-common && add-apt-repository -y ppa:bitcoin/bitcoin && apt update && apt-get -qq install libdb4.8-dev && apt-get -qq install libdb4.8++-dev && apt-get -qq install libminiupnpc-dev && apt-get -qq install libqt4-dev libprotobuf-dev protobuf-compiler && apt-get -qq install libqrencode-dev && apt-get -qq install git && apt-get -qq install pkg-config && apt-get -qq install libzmq3-dev
apt-get -qq install aptitude

  aptitude -y -q install fail2ban
  service fail2ban restart

  apt-get -qq install ufw
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow ssh
  ufw allow 40001/tcp
  yes | ufw enable

# Install Arktur daemon
wget $TARBALLURL && tar -xvf $TARBALLNAME -C $USERHOME/  && rm $TARBALLNAME
cp $USERHOME/arkturd /usr/local/bin
cp $USERHOME/arktur-cli /usr/local/bin
rm $USERHOME/arktur*
chmod 755 /usr/local/bin/arktur*
mkdir $USERHOME/.arktur

su - $USER -c arktur-cli stop
sleep 6

touch $USERHOME/.arktur/arktur.conf
cat > $USERHOME/.arktur/arktur.conf << EOL
rpcuser=${RPCUSER}
rpcpassword=${RPCPASSWORD}
rpcallowip=127.0.0.1
rpcport=40002
listen=1
server=1
daemon=1
maxconnections=256
masternodeaddr=${EXTERNALIP}:40001
masternodeprivkey=${KEY}
masternode=1
EOL
chmod 0600 $USERHOME/.arktur/arktur.conf
chown -R $USER:$USER $USERHOME/.arktur

sleep 1

su - $USER -c arkturd 
echo "Downloading wallet, pls wait..."

sleep 50

clear

echo "Your masternode is syncing. Please wait for this process to finish."
echo "This can take up to a few hours. Do not close this window." && echo ""
BLOCKCOUNT=0

until su -c "arktur-cli mnsync status 2>/dev/null | grep '\"IsBlockchainSynced\" : true' > /dev/null" $USER; do
  for (( i=0; i<${#CHARS}; i++ )); do
    sleep 2
    BLOCKCOUNT=`su -l -c "arktur-cli getblockcount" $USER`
	echo -en "${CHARS:$i:1}" "$BLOCKCOUNT" "\r"
  done
done

clear

cat << EOL

Start your masternode. Go to your desktop wallet and
add string to masternode.cogf file:
MN ${EXTERNALIP}:40001 ${KEY} [10k desposit transaction id. 'masternode outputs'] [10k desposit transaction index. 'masternode outputs']
Then restart wallet and wait full sync.

enter the following line into your debug console (Tools->Debug console):
startmasternode "alias" "0" "MN"


EOL

read -p "Press Enter to continue after you've done that. " -n1 -s

clear

sleep 1
sleep 1
clear
su -c "/usr/local/bin/arktur-cli masternode status" $USER
sleep 5

echo "" && echo "If you see @Masternode successfully started@ - Masternode setup completed." && echo ""

