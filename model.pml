
owner "jenkins" systemPassword "jenkins" // Unix user account that runs the Jenkins daemon
adminPassword "admin"

jenkinsWarDir "/usr/lib/{{ product.owner }}" directory() owner "{{ product.owner }}" command "provision"
webroot "/var/cache/{{ product.owner }}/war" directory() owner "{{ product.owner }}" command "deploy"
jenkinsHome "/home/{{ product.owner }}/.jenkins" directory() owner "{{ product.owner }}" env "JENKINS_HOME" command "deploy"
jenkinsLog "/var/log/{{ product.owner }}" directory() owner "{{ product.owner }}" persistent("JENKINS_LOG_DIR") command "deploy"
pluginDir "{{ product.jenkinsHome }}/plugins"

startCmd "start.sh" start() script() async(delay: "50s") user "{{ product.owner }}"
stopScript "stop.sh" stop() script() user "{{ product.owner }}"

http {
    port 8080 exposed("JENKINS_HTTP_PORT") // Port Jenkins is listening on. Set to -1 to disable
    listenAddress '' // IP address Jenkins listens on for HTTP requests. Default is all interfaces (0.0.0.0).
}

https {
    port 0 // HTTPS port Jenkins is listening on. Default is disabled.
    listenAddress ''
    keystorePath '' // Path to the keystore in JKS format (as created by the JDK 'keytool').
    keystorePassword ''
}

javaOptions '-Djava.awt.headless=true'

debugLevel 5 // Debug level for logs -- the higher the value, the more verbose. 5 is info
enableAccessLog "no" // Whether to enable access logging or not (yes,no)

handlerMax 100 // Maximum number of HTTP worker threads.
handlerIdle 20 // Maximum number of idle HTTP worker threads.

jdkDir "/logiciels/jdk"
javaHome "{{ product.jdkDir }}/jdk1.8.0_112" env "JAVA_HOME" command "bootstrap"
