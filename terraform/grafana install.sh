#!/bin/sh
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
wget -q -O /tmp/grafana-key.gpg https://packages.grafana.com/gpg.key
sudo apt update
sudo apt install -y grafana
sudo systemctl start grafana-server
sudo systemctl status grafana-server