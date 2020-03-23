#!/bin/bash

set -x

sudo apt-get update -y
sudo apt-get install -y postgresql-client
sudo apt-get install -y awscli 


aws s3 cp s3://${s3_installation_bucket}/ /tmp --region ${s3_region} --recursive 

# application settings
sed -i 's/tf_enc_password/${dashboard_default_password}/g' /tmp/application-settings.json
sed -i 's/tf_hostname/${fqdn}/g' /tmp/application-settings.json
sed -i 's/tf_pg_dbname/${pg_dbname}/g' /tmp/application-settings.json 
sed -i 's/tf_pg_netloc/${pg_netloc}/g' /tmp/application-settings.json 
sed -i 's/tf_pg_password/${pg_password}/g' /tmp/application-settings.json 
sed -i 's/tf_pg_user/${pg_user}/g' /tmp/application-settings.json 
sed -i 's/s3_bucket_svc/${s3_bucket_svc}/g' /tmp/application-settings.json 
sed -i 's/tf_s3_region/${s3_region}/g' /tmp/application-settings.json 

# replicated settings
sed -i 's/tf_password/${dashboard_default_password}/g' /tmp/replicated.conf
sed -i 's/tf_fqdn/${fqdn}/g' /tmp/replicated.conf
sed -i 's#tls_cert#${tls_cert}#g' /tmp/replicated.conf
sed -i 's#tls_key#${tls_key}#g' /tmp/replicated.conf
sed -i 's#settings_file#${settings_file}#g' /tmp/replicated.conf
sed -i 's#license_file#${license_file}#g' /tmp/replicated.conf
sed -i 's#airgap_binary#${airgap_binary}#g' /tmp/replicated.conf

# silent restore settings
sed -i 's/your_bucket_to_store_snapshots/${s3_bucket_svc_snapshots}/g' /tmp/silent_restore.sh
sed -i 's/region_of_the_bucket/${s3_region}/g' /tmp/silent_restore.sh

# replicated config to etc
sudo cp /tmp/replicated.conf /etc/replicated.conf

# if snapshots already exist on S3 restore latest snapshot
#(aws s3 ls s3://${s3_bucket_svc_snapshots}/files/db.dump --region ${s3_region}) && {
#  echo "Restoring everything from backup"
#  sudo chmod +x /tmp/silent_restore.sh
#  sudo bash /tmp/silent_restore.sh
#}

# if there are no existing snapshots, perform fresh install
(aws s3 ls s3://${s3_bucket_svc_snapshots}/files/db.dump --region ${s3_region}) || {
  echo "Performing fresh installation in silent mode" 
  echo "Creating DBs" 
  export PGPASSWORD=${pg_password}; psql -h ${pg_netloc} -d ${pg_dbname} -U ${pg_user} -p ${pg_port} -a -q -f /tmp/postgresql.sql


  sudo dpkg --install /tmp/${containerd}
  sudo dpkg --install /tmp/${lib_dep} 
  sudo dpkg --install /tmp/${docker_cli} 
  sudo dpkg --install /tmp/${docker_ce}

  # Untar installer
  sudo tar -xvf /tmp/${airgap_installer} -C /tmp 

  # Install
  cd /tmp
  nohup sudo bash ./install.sh airgap no-proxy private-address=$(curl http://169.254.169.254/latest/meta-data/local-ipv4) public-address=$(curl http://169.254.169.254/latest/meta-data/public-ipv4) | tee installer.log
}