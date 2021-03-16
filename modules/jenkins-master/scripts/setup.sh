## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

#!/bin/bash
set -e -x

sudo echo "OCI CLI Install"

printf 'y\n' | sudo yum install python3-pip
sudo pip3 install oci-cli --upgrade

sleep 10

function waitForJenkins() {
    echo "Waiting for Jenkins to launch on ${http_port}..."

    while ! timeout 1 bash -c "echo > /dev/tcp/localhost/${http_port}"; do
      sleep 1
    done

    echo "Jenkins launched"
}

sudo echo "Java Install"

# configure key per opc user

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDqk2hEzWXrMtGphHwp3QHs3paf9OGjpOxUaDxTjbalGliLh7aBlWhKbrIHyzyYmX08UuzmtftHwitZSiVUV0FqgedGEPvOSOeujDMB41oMPug3PANweYO/y3LL0CkLlig5P9vT5DOnaqCkAYtnSNyhb3TF9KJF5VN2pO3hD9FIFcmgGT1qJkb4Pr7e47Zx2GxZtzdRYcuQCfoNSBa4in63VBHlvzeQSViNC4Ssiicjik98XU4bbTcUPuWId01q5UbpzIwmtgsfiX5Khp4ncKMX37d+qD70vlb0Vi/xSiPvofB6RCTw0lXlZne+AhBbgL4bReG4PIH3BwJ+7YdUHdWv luca.bindioracle.com@printer.homenet.telecomitalia.it" >>/home/opc/.ssh/authorized_keys

# configure epel repo 
cat >>/etc/yum.repos.d/epel-yum-ol7.repo<<EOF
[ol7_epel]
name=Oracle Linux \$releasever EPEL (\$basearch)
baseurl=http://yum.oracle.com/repo/OracleLinux/OL7/developer_EPEL/\$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1
EOF



# Install Java for Jenkins
sudo yum install -y java-1.8.0-openjdk

sleep 10

# Install xmlstarlet used for XML config manipulation curl -L -O https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh chmod +x install.sh
sudo yum install -y xmlstarlet

sudo echo "step -> docker install"

sudo yum -y update || true
sudo yum install -y docker-engine
sudo systemctl start docker
sudo systemctl enable docker

sleep 10

sudo echo "Installing jenkins"

# Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install -y jenkins-${jenkins_version}

# Config Jenkins Http Port
sudo sed -i '/JENKINS_PORT/c\ \JENKINS_PORT=\"${http_port}\"' /etc/sysconfig/jenkins
sudo sed -i '/JENKINS_JAVA_OPTIONS/c\ \JENKINS_JAVA_OPTIONS=\"-Djenkins.install.runSetupWizard=false -Djava.awt.headless=true\"' /etc/sysconfig/jenkins
# Start Jenkins
sudo service jenkins restart
sudo chkconfig --add jenkins

# Set httpport on firewall
sudo firewall-cmd --zone=public --permanent --add-port=${http_port}/tcp
sudo firewall-cmd --zone=public --permanent --add-port=${jnlp_port}/tcp
sudo firewall-cmd --zone=public --permanent --add-port=443/tcp
sudo firewall-cmd --reload

waitForJenkins

# UPDATE PLUGIN LIST
curl  -L http://updates.jenkins-ci.org/update-center.json | sed '1d;$d' | curl -X POST -H 'Accept: application/json' -d @- http://localhost:${http_port}/updateCenter/byId/default/postBack

sleep 10

waitForJenkins

# INSTALL CLI
sudo wget -P /var/lib/jenkins/ http://localhost:8080/jnlpJars/jenkins-cli.jar

sleep 10


# Set Agent Port
xmlstarlet ed -u "//slaveAgentPort" -v "${jnlp_port}" /var/lib/jenkins/config.xml > /home/opc/jenkins_config.xml
sudo mv /home/opc/jenkins_config.xml /var/lib/jenkins/config.xml

# Initialize Jenkins User Password Groovy Script
export PASS=${jenkins_password}

sudo -u jenkins mkdir -p /var/lib/jenkins/init.groovy.d
sudo mv /home/opc/default-user.groovy /var/lib/jenkins/init.groovy.d/default-user.groovy

#configure token 
export crumb= $(curl -s -u devops:dev123 http://localhost:8080/crumbIssuer/api/json|grep -w crumb|awk -F\" '{print $4}')
curl 'http://localhost:8080/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken' --data 'newTokenName=my-second-token' --user admin:${jenkins_password} -H 'Jenkins-Crumb:$(crumb)'

sudo service jenkins restart

waitForJenkins

sleep 60

# INSTALL PLUGINS
sudo java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:${http_port} -auth admin:$PASS install-plugin ${plugins}

# RESTART JENKINS TO ACTIVATE PLUGINS
sudo java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:${http_port} -auth admin:$PASS restart



