handler "plugins.groovy"
artifact("http://updates.jenkins-ci.org/download/war/2.32.1/jenkins.war") {
    to "{{ product.jenkinsWarDir }}"
}
artifact("http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-x64.tar.gz") {
    to "{{ product.jdkDir }}"
    unpack true
}

def pluginList=[
    "cloudbees-folder:5.16",
    "build-timeout:1.18",
    "ant:1.4",
    "antisamy-markup-formatter:1.5",
    "credentials-binding:1.10",
    "timestamper:1.8.7",
    "ws-cleanup:0.32",
    "git:3.0.1",
    "subversion:2.7.1",
    "gradle:1.25",
    "github-organization-folder:1.5",
    "workflow-aggregator:2.4",
    "pipeline-stage-view:2.4",
    "ssh-slaves:1.12",
    "matrix-auth:1.4",
    "pam-auth:1.3",
    "ldap:1.13",
    "email-ext:2.53"
]

def mirror = "http://updates.jenkins-ci.org"
pluginList.each { item ->
    def (name,version)=item.split(":")
    artifact("$mirror/download/plugins/$name/$version/${name}.hpi") {
        to "{{ product.pluginDir }}"
        command "deploy"
    }
}

