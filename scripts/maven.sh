#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# maven 项目操作脚本
# @author Zhang Peng
# ------------------------------------------------------------------------------

# 装载其它库
ROOT=`dirname ${BASH_SOURCE[0]}`
source ${ROOT}/utils.sh

# 执行 maven 操作
# @param $1: 第一个参数为 maven 项目路径
# @param $2: 第二个参数为 maven 操作，如 package、install、deploy
# @param $3: 第三个参数为 maven profile 【非必填】
mavenOperation() {
	local source=$1
	local lifecycle=$2
	local profile=$3

	mavenCheck ${source}
    if [[ "${SUCCEED}" != "$?" ]]; then
        return ${FAILED}
    fi

    if [[ ! "${lifecycle}" ]]; then
        printError "please input maven lifecycle"
        return ${FAILED}
    fi

    local mvnCli="mvn clean ${lifecycle} -DskipTests=true -B -U"

    if [[ ${profile} ]]; then
        mvnCli="${mvnCli} -P${profile}"
    fi

    cd ${source}
    if [[ -f "${source}/settings.xml" ]]; then
        mvnCli="${mvnCli} -s ${source}/settings.xml"
    fi

    callAndLog "${mvnCli}"
    cd -
    return ${SUCCEED}
}

# 判断指定路径下是否为 maven 工程
# @param $1: 第一个参数为 maven 项目路径
mavenCheck() {
    local source=$1
    if [[ -d "${source}" ]]; then
		cd ${source}
		if [[ -f "${source}/pom.xml" ]]; then
			return ${YES}
		else
			printError "pom.xml is not exists"
			return ${NO}
		fi
		cd -
		return ${YES}
	else
		printError "please input valid maven project path"
		return ${NO}
	fi
}

##################################### MAIN #####################################
printInfo ">>>> maven build begin\n"

if [[ ! $1 ]]; then
    printError "<<<< options invalid\n"
    printf "\n${C_B_MAGENTA}"
    printf "<Introduction>\n"
    printf "script params：lifecycle [profile]\n"
    printf "\t lifecycle: maven lifecycle. Eg. package, install, deploy\n"
    printf "\t profile: maven profile\n"
    printf "Example: sh maven.sh install prod\n"
    printf "${C_RESET}\n"
    exit ${FAILED}
fi

mavenOperation ${ROOT}/.. $1 $2
RESULT=$?
if [[ "${RESULT}" == "${SUCCEED}" ]]; then
    printInfo "<<<< maven build succeed\n"
    exit ${SUCCEED}
else
    printError "<<<< maven build failed\n"
    exit ${FAILED}
fi
