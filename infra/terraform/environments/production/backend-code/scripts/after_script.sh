#!/bin/bash
set -x
chown -R ubuntu:ubuntu /home/ubuntu/nodeapp/
echo "***starting server-backend-admin-api-prod application ***" >> /tmp/nodeapp-api-prod_deploy_logs
runuser -l ubuntu -c 'cd /home/ubuntu/nodeapp && sudo pm2 start server.mjs --name server  --silent' >> /tmp/nodeapp-api-prod_deploy_logs
s1=`pm2 status | grep -we server | awk '{print $12}'`
sleep 5
s2=`pm2 status | grep -we server | awk '{print $12}'`
if [ $s1 == $s2 ]
then
echo "BUILD SUCCESSFUL" >> /tmp/nodeapp-api-prod_deploy_logs
echo >> /tmp/nodeapp-api-prod_deploy_logs
else
echo "Node process is restarting" >> /tmp/nodeapp-api-prod_deploy_logs
echo >> /tmp/nodeapp-api-prod_deploy_logs
fi