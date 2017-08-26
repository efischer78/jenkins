#!/bin/bash

echo "2.0" > /home/{{ .product.owner }}/.jenkins/jenkins.install.InstallUtil.lastExecVersion


script=$(cat <<EOF
import jenkins.install.InstallState
import hudson.security.HudsonPrivateSecurityRealm.Details;

def instance = Jenkins.instance
//instance.setInstallState(InstallState.RUNNING)

def user = hudson.model.User.current();
user.addProperty(Details.fromPlainPassword('{{ .product.adminPassword }}'))
instance.save()
instance.restart()
EOF
)
adminPassword=$(cat /home/{{ .product.owner }}/.jenkins/secrets/initialAdminPassword)
mytoken=$(curl --user "admin:$adminPassword" -s http://localhost:{{ .product.http.port }}/crumbIssuer/api/json | python -c 'import sys,json;j=json.load(sys.stdin);print j["crumbRequestField"] + "=" + j["crumb"]')

curl --user "admin:$adminPassword" -d "$mytoken" --data-urlencode "script=$script" http://localhost:{{ .product.http.port }}/scriptText

