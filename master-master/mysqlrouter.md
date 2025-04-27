systemctl stop mysqlrouter
sudo -u mysqlrouter -H bash
cd ~/bootstrap
mysqlrouter --bootstrap clusteradmin@10.10.10.94:3306 --directory ~/bootstrap --force
