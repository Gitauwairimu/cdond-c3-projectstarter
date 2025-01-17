#!/bin/bash

useradd --no-create-home prometheus
mkdir /etc/prometheus
mkdir /var/lib/prometheus

wget https://github.com/prometheus/prometheus/releases/download/v2.19.0/prometheus-2.19.0.linux-amd64.tar.gz
tar xvfz prometheus-2.19.0.linux-amd64.tar.gz

cp prometheus-2.19.0.linux-amd64/prometheus /usr/local/bin
cp prometheus-2.19.0.linux-amd64/promtool /usr/local/bin/
cp -r prometheus-2.19.0.linux-amd64/consoles /etc/prometheus
cp -r prometheus-2.19.0.linux-amd64/console_libraries /etc/prometheus

cp prometheus-2.19.0.linux-amd64/promtool /usr/local/bin/
rm -rf prometheus-2.19.0.linux-amd64.tar.gz prometheus-2.19.0.linux-amd64

cat > /etc/prometheus/prometheus.yml << EOF
global:
  scrape_interval: 15s
  external_labels:
    monitor: 'prometheus'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

EOF

mkdir -p /etc/systemd/system/
touch /etc/systemd/system/prometheus.service

cat > /etc/systemd/system/prometheus.service << EOF
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
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target

EOF


chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool
chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries
chown -R prometheus:prometheus /var/lib/prometheus

systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus