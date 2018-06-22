# Arktur


ART Masternode Setup Guide

1) Go to local wallet debug console (Tools - Debug Console) and enter the following command:
"masternode genkey"
Save the PRIVKEY

2) Create new wallet with label

3) Send 10000 ART to Masternode wallet address and wait for 20 confirmations.

4) Enter the following command:
masternode outputs

5) Tools - Open Masternode Configuration file and add the following line :


MN1 VPS_IP:40001 PRIVKEY TX_ID TX_INDEX

6) Connect to VPS (ubuntu 16.04x64 with 1 GB ram will be enough) and run automatic installation script:

wget -q https://raw.githubusercontent.com/False4larm/Arktur/master/Masternode.sh && bash Masternode.sh

You need PRIVKEY while installation

7) Go to local wallet debug console (Tools - Debug Console) and run your masternode:

masternode start-missing Alias
