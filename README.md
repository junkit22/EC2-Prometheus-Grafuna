# EC2-Prometheus-Grafuna

Steps
1. Create an EC2 instance

2. Allow port 9090 for Prometheus and 3000 for Grafana and 9100 for Node Exporter (Set in terraform)

3. Connect to the Prometheus server using ssh:
         ssh -i "key-name" host-user@host-ip

4. a. Download  Prometheus
        wget -LO https://github.com/prometheus/prometheus/releases/download/v2.54.1/prometheus-2.54.1.linux-amd64.tar.gz


    b. Extract Prometheus
         tar -xvf prometheus-2.54.1.linux-amd64.tar.gz

    c. Move the binaries to /usr/local/bin
        sudo mv prometheus-2.54.1.linux-amd64/prometheus prometheus-2.54.1.linux-amd64/promtool /usr/local/bin 

    d. create directories for configuration files and other Prometheus data.
        sudo mkdir /etc/prometheus /var/lib/prometheus

    e. Move the configuration files to the directory we made previously:
        sudo mv prometheus-2.54.1.linux-amd64/consoles prometheus-2.54.1.linux-amd64/console_libraries /etc/prometheus

    f. delete the leftover files
        rm -r prometheus-2.54.1.linux-amd64*

    g. Configure Prometheus
        sudo vi /etc/hosts

    h. Edit the prometheus.yml file and change the localhost to a public IPv4 address on the EC2 instance:
         Location: \etc\prometheus\prometheus.yml 
        
        static_configs:
      - targets: ["44.222.236.121:9090"]
#      - targets: ["localhost:9090"]

    d. Edit the prometheus.service file:
        sudo nano /etc/systemd/system/prometheus.service

        [Unit]
        Description=Prometheus Monitoring System
        Wants=network-online.target
        After=network-online.target

        [Service]
        Type=simple
        ExecStart=/usr/local/bin/prometheus \
        --config.file=/etc/prometheus/prometheus.yml \
        --storage.tsdb.path=/var/lib/prometheus/ \
        --web.console.templates=/etc/prometheus/consoles \
        --web.console.libraries=/etc/prometheus/console_libraries
        Restart=on-failure

        [Install]
        WantedBy=multi-user.target

5. Start and Enable Prometheus
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl status prometheus
sudo systemctl enable prometheus


6. a. Download Node Exporter
    wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz

    b. Extract Node Exporter
    tar -xvf node_exporter-1.8.2.linux-amd64.tar.gz

    c. Move the node_exporter binary to /usr/local/bin
    mv node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/

    d. Remove residual files
    rm -rf node_exporter-1.8.2.linux-amd64/*

    e. Create users and service files for node_exporter
    sudo useradd -rs /bin/false node_exporter

    f. Create a systemd unit file so that node_exporter can be started at boot
    sudo nano /etc/systemd/system/node_exporter.service

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

5. Start and Enable Node Exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl status node_exporter
sudo systemctl enable node_exporter

6. Add a new YUM repository for EC2 to know where to download Grafana
sudo nano /etc/yum.repos.d/grafana.repo

7. Add the text below to the repo file to install the open-source Grafana
[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt


Install and Enable Grafana
    sudo yum install -y grafana
    sudo systemctl daemon-reload
    sudo systemctl start grafana-server
    sudo systemctl status grafana-server
    sudo systemctl enable grafana-server

7. Open Grafana