#!/bin/bash

# Update yumn package repositories
yum update -y
yum install stress-ng -y

# Download and extract prometheus installation file, move the binaries to the directory "prometheus-files"
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.54.1/prometheus-2.54.1.linux-amd64.tar.gz
tar -xvf prometheus-2.54.1.linux-amd64.tar.gz
rm -f prometheus-2.54.1.linux-amd64.tar.gz # remove the installation file
sudo mv prometheus-2.54.1.linux-amd64 prometheus-files

# Create a user for Prometheus and assign Prometheus as the owner of these directories
groupadd -f prometheus
useradd -g prometheus --no-create-home --shell /bin/false prometheus

# Create prometheus directories to store configuration files and data 
sudo mkdir /etc/prometheus 
sudo mkdir /var/lib/prometheus

# Change ownership of directory to user for Prometheus
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus

# Copy the binaries prometheus and promtool from the prometheus-files directory to /usr/local/bin and update the ownership to the user prometheus.
cp prometheus-files/prometheus /usr/local/bin/
cp prometheus-files/promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

# Move the directories consoles and console_libraries from the prometheus-files folder to /etc/prometheus, and change the ownership to the user prometheus
cp -r prometheus-files/consoles /etc/prometheus
cp -r prometheus-files/console_libraries /etc/prometheus
chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries

# create prometheus config file
cat <<EOF | tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 10s
#  external_labels: 'prometheus'

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets: ['localhost:9093']

rule_files:
  - "cpu_thresholds_rules.yml"
  - "storage_thresholds_rules.yml"
  - "memory_thresholds_rules.yml"

scrape_configs:
  - job_name: 'prometheus_metrics'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter_metrics'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']
EOF

chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Setup Prometheus Service File
cat <<EOF | tee  /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Download and extract node_exporter installation file and move binary to /usr/local/bin
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
tar -xvf node_exporter-1.8.2.linux-amd64.tar.gz
rm -f node_exporter-1.8.2.linux-amd64.tar.gz
mv node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/

# create group/user for node_exporter
groupadd -f node_exporter
useradd -g node_exporter --no-create-home --shell /bin/false node_exporter

# Create Node Exporter Service
cat <<EOF | tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Download and install grafana
curl -LO https://dl.grafana.com/enterprise/release/grafana-enterprise-11.1.3-1.x86_64.rpm
yum localinstall grafana-enterprise-11.1.3-1.x86_64.rpm -y
rm -f grafana-enterprise-11.1.3-1.x86_64.rpm

# Configure Provisioning
sed -i 's|;provisioning = conf/provisioning|provisioning = /etc/grafana/provisioning|g' /etc/grafana/grafana.ini

cat <<EOF | tee /etc/grafana/provisioning/datasource.yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://localhost:9090
    isDefault: true
    editable: true
EOF

# Reload System Manager
systemctl daemon-reload

# Start and Enable Services
systemctl start prometheus
systemctl start node_exporter
systemctl start grafana-server
systemctl enable prometheus
systemctl enable node_exporter
systemctl enable grafana-server