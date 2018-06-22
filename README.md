# Arktur
MN Script

ART Masternode Setup Guide

1) Go to local wallet debug console (Tools - Debug Console) and enter the following command:
masternode genkey
Save the result (PRIVKEY)

2) Create new wallet with label

2) Send 5000 ART to Masternode wallet address and wait for 15 confirmations.

3) Enter the following command:
masternode outputs
Proof of transaction (TX_ID and TX_INDEX)

4) Tools - Open Masternode Configuration file and add the following line (port=40001):
MN1 VPS_IP:40001 PRIVKEY TX_ID TX_INDEX

5) Connect to VPS server Terminal and run automatic installation script:

wget -q https://raw.githubusercontent.com/False4larm/Arktur/master/Masternode.sh && bash installer.sh

You need PRIVKEY while installation

6) Go to local wallet debug console (Tools - Debug Console) and run your masternode:

masternode start-missing Alias


Useful commands (VPS):

cts-cli getinfo
cts-cli mnsync status
cts-cli masternode status(edited)

