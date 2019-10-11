#!/usr/bin/groovy

def call(Closure body=null) {
	this.vars = [:]
	call(vars, body)
}

def call(Map vars, Closure body=null) {

    echo "[JPL] Executing `vars/gitCheckoutBMRepo.groovy`"

    vars = vars ?: [:]

    def GIT_REPO_PROJECT = vars.get("GIT_PROJECT_TEST", "NABLA").trim()
    def GIT_PROJECT = vars.get("GIT_PROJECT", "nabla").trim()
    def GIT_BROWSE_URL = vars.get("GIT_BROWSE_URL", "https://github.com/AlbanAndrieu//${GIT_PROJECT}/")
    def GIT_URL = vars.get("GIT_URL", "https://github.com/AlbanAndrieu/${GIT_PROJECT}.git")
    def JENKINS_CREDENTIALS = vars.get("JENKINS_CREDENTIALS", 'jenkins-https')
    //def GIT_URL = vars.get("GIT_URL", "ssh://git@github.com:AlbanAndrieu/${GIT_PROJECT}.git")
    //def JENKINS_CREDENTIALS = vars.get("JENKINS_CREDENTIALS", 'jenkins-ssh')

    def relativeTargetDir = vars.get("relativeTargetDir", GIT_PROJECT)
    def isDefaultBranch = vars.get("isDefaultBranch", false).toBoolean()

    //echo "isDefaultBranch=" + isDefaultBranch

    def GIT_BRANCH_NAME_BUILDMASTER = vars.get("GIT_BRANCH_NAME_BUILDMASTER", "develop")

	checkout([
		$class: 'GitSCM',
		//branches: scm.branches,
		//branches: [[name: env.GIT_BRANCH_NAME_BUILDMASTER]],
		branches: getDefaultCheckoutBranches(isDefaultBranch, GIT_BRANCH_NAME_BUILDMASTER),
		browser: [
			$class: 'Stash',
			repoUrl: "${GIT_BROWSE_URL}"],
		doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
		//doGenerateSubmoduleConfigurations: false,
		extensions: getDefaultCheckoutExtensions(isDefaultBranch, relativeTargetDir),
		gitTool: 'git-latest',
		submoduleCfg: [],
		userRemoteConfigs: [[
			credentialsId: "${JENKINS_CREDENTIALS}",
			url: "${GIT_URL}"]
		]
	])

    if (body) { body() }

}
