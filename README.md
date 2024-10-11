# EC2-Prometheus-Grafuna
https://medium.com/@bhagyashritupe96/setting-up-prometheus-node-exporter-and-grafana-on-ec2-a-step-by-step-guide-a1fd20486343
Steps
1. Create an EC2 instance

2. Connect to the Prometheus server using ssh:
    ssh -i "key-name" host-user@host-ip

3. Install and Enable Grafana
    sudo yum install grafana
    sudo systemctl daemon-reload
    sudo systemctl start grafana-server
    sudo systemctl status grafana-server
    sudo systemctl enable grafana-server

3. Open Grafana
    http://localhost:3000

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

    c. Edit the prometheus.yml file and change the localhost to a public IPv4 address on the EC2 instance:
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

6. Allow port 9090 for Prometheus and 3000 for Grafana (Set in terraform)