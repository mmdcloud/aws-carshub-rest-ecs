#!/bin/bash
set -x
echo "** nodeapp-api-prod process status **" >> /tmp/nodeapp-api-prod_deploy_logs
runuser -l ubuntu -c 'sudo pm2 status' | grep -wo server
if [  $? -ne 0 ];
then
   echo "############################## pm2 not running #################################" >> /tmp/nodeapp-api-prod_deploy_logs
else
   echo "############################## pm2 already running Deleting ####################" >> /tmp/nodeapp-api-prod_deploy_logs
    runuser -l ubuntu -c 'sudo pm2 delete server'
fi
 
rm -rf /home/ubuntu/nodeapp
 
if [ ! -d /home/ubuntu/nodeapp ]; then
runuser -l ubuntu -c 'mkdir -p /home/ubuntu/nodeapp' >> /tmp/nodeapp-prod_deploy_logs
fi