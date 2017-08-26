package jenkins.handlers

/**
 * Created by Eric-Eurocom on 03/02/2017.
 */

import org.iodasolutions.piper.dsl.artifact.Artifact

import java.util.jar.JarFile
List<Artifact> artifacts = ctx.artifacts
List<Artifact> finalArtifacts = []
/**
 * Created by Eric-Eurocom on 03/02/2017.
 */
artifacts.each { artifact ->
    finalArtifacts << artifact
    if (artifact.name().endsWith(".hpi")) {
        inspectHpiArtifact(artifact, finalArtifacts)
    }
}
filterArtifacts(finalArtifacts)
ctx.artifacts = finalArtifacts

private inspectHpiArtifact(Artifact artifact, List<Artifact> artifactsOUT) {
    def file = artifact.asFile()
    def pluginJar = new JarFile(file)
    def entry = pluginJar.manifest.mainAttributes.entrySet().find { it.key.toString() == 'Plugin-Dependencies' }
    if (entry) {
        def artifactsList = entry.value.toString().split(",")
        artifactsList.each { item ->
            item = item.replace(";resolution:=optional", "")
            def (name, version) = item.split(":")
            def location = artifact.mirror() + "/download/plugins/$name/$version/${name}.hpi"
            def childArtifact = new Artifact(location: location,
                    command: artifact.command,
                    to: artifact.to)
            childArtifact.resolve()
            artifactsOUT << childArtifact
            inspectHpiArtifact(childArtifact, artifactsOUT)
        }
    }

}

def filterArtifacts(List<Artifact> artifacts) {

    def hpiArtifacts = artifacts.findAll { it.name().toString().endsWith(".hpi")}
    List<Artifact> result = artifacts.findAll { !it.name().toString().endsWith(".hpi")}

    Map<String, List<Artifact>> artifactsByName = [:]
    hpiArtifacts.each { artifact ->
        List<Artifact> list = artifactsByName."${artifact.name()}"
        if (!list) {
            list = []
            artifactsByName["${artifact.name()}"] = list
        }
        list << artifact
    }
    artifactsByName.each { k,List<Artifact> v ->
        v.sort { Artifact a, Artifact b ->
            def versionA = getVersion(a)
            def versionB = getVersion(b)
            return compare(versionA, versionB)
        }
        result << v.last()
    }
    artifacts.clear()

    artifacts.addAll(result)
}
String getVersion(Artifact artifact) {
    artifact.location.tokenize("/").dropRight(1).last()
}

int compare(String versionA, String versionB) {
    def dotACount = versionA.count(".")
    def dotBCount = versionB.count(".")
    if (dotACount > dotBCount) {
        (dotACount - dotBCount).times { versionB += ".0" }
    }
    else if (dotACount < dotBCount) {
        (dotBCount - dotACount).times { versionA += ".0" }
    }
    def versionATokens = versionA.tokenize(".")
    def versionBTokens = versionB.tokenize(".")
    int value = 0
    versionATokens.eachWithIndex{ String entry, int i ->
        if (value == 0) {
            def valueA = Integer.parseInt(entry)
            def valueB = Integer.parseInt(versionBTokens[i])
            if (valueA < valueB) {
                value = -1
            } else if (valueA > valueB){
                value = 1
            }
        }
    }
    return value
}