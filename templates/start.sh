#!/bin/bash
PARAMS="--logfile={{ .product.jenkinsLog }}/jenkins.log --webroot={{ .product.webroot }} \
--httpPort={{ .product.http.port }} \
--debug={{ .product.debugLevel }} --handlerCountMax={{ .product.handlerMax }} --handlerCountMaxIdle={{.product.handlerIdle }} "


{{ if ne .product.http.listenAddress "" }}
    PARAMS="$PARAMS --httpListenAddress={{ .product.http.listenAddress }}"
{{ end }}
{{ if eq .product.enableAccessLog "yes" }}
    PARAMS="$PARAMS --accessLoggerClassName=winstone.accesslog.SimpleAccessLogger --simpleAccessLogger.format=combined --simpleAccessLogger.file={{ .product.jenkinsLog }}/access_log"
{{ end }}
{{ if gt .product.https.port 0.0 }}
    PARAMS="$PARAMS --httpsPort={{ .product.https.port }} --httpsKeyStore={{ .product.https.keystorePath }} --httpsKeyStorePassword='{{ .product.https.keystorePassword }}' --listenAddress={{ .product.https.listenAddress }}"
{{ end }}

JAVA_CMD="{{ .product.javaHome }}/bin/java {{ .product.javaOptions }} -jar {{ .product.jenkinsWarDir }}/jenkins.war"

echo "Demarrage de Jenkins"
echo "$JAVA_CMD $PARAMS"
$JAVA_CMD $PARAMS
