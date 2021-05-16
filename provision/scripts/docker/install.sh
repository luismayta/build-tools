#!/bin/bash
# shellcheck disable=SC1091,SC2164,SC2034,SC1072,SC1073,SC1009

# Docker installer for Debian, Ubuntu, CentOS, Amazon Linux 2, Fedora, Oracle Linux 8 and Arch Linux
# https://github.com/hadenlabs/build-tools/docker/install.sh

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;36m"
NORMAL="\033[0m"

function messageError() {
    printf "${RED}%s${NORMAL}\n" "[ERROR]: ${1}"
    exit 1
}

function messageInfo() {
    printf "${BLUE}%s${NORMAL}\n" "[INFO]: ${1}"
}

function messageWarning() {
    printf "${YELLOW}%s${NORMAL}\n" "[WARNING]: ${1}"
}

function messageSuccess() {
    printf "${GREEN}%s${NORMAL}\n" "🍺️ [SUCCESS]: ${1}"
}


function isRoot() {
	if [ "$EUID" -ne 0 ]; then
		return 1
	fi
}

function checkOS() {
	if [[ -e /etc/debian_version ]]; then
		OS="debian"
		source /etc/os-release

		if [[ $ID == "debian" || $ID == "raspbian" ]]; then
			if [[ $VERSION_ID -lt 9 ]]; then
				echo "⚠️ Your version of Debian is not supported."
				echo ""
				echo "However, if you're using Debian >= 9 or unstable/testing then you can continue, at your own risk."
				echo ""
				until [[ $CONTINUE =~ (y|n) ]]; do
					read -rp "Continue? [y/n]: " -e CONTINUE
				done
				if [[ $CONTINUE == "n" ]]; then
					exit 1
				fi
			fi
		elif [[ $ID == "ubuntu" ]]; then
			OS="ubuntu"
			MAJOR_UBUNTU_VERSION=$(echo "$VERSION_ID" | cut -d '.' -f1)
			if [[ $MAJOR_UBUNTU_VERSION -lt 16 ]]; then
				echo "⚠️ Your version of Ubuntu is not supported."
				echo ""
				echo "However, if you're using Ubuntu >= 16.04 or beta, then you can continue, at your own risk."
				echo ""
				until [[ $CONTINUE =~ (y|n) ]]; do
					read -rp "Continue? [y/n]: " -e CONTINUE
				done
				if [[ $CONTINUE == "n" ]]; then
					exit 1
				fi
			fi
		fi
	elif [[ -e /etc/system-release ]]; then
		source /etc/os-release
		if [[ $ID == "fedora" || $ID_LIKE == "fedora" ]]; then
			OS="fedora"
		fi
		if [[ $ID == "centos" ]]; then
			OS="centos"
			if [[ ! $VERSION_ID =~ (7|8) ]]; then
				echo "⚠️ Your version of CentOS is not supported."
				echo ""
				echo "The script only support CentOS 7 and CentOS 8."
				echo ""
				exit 1
			fi
		fi
		if [[ $ID == "ol" ]]; then
			OS="oracle"
			if [[ ! $VERSION_ID =~ (8) ]]; then
				echo "Your version of Oracle Linux is not supported."
				echo ""
				echo "The script only support Oracle Linux 8."
				exit 1
			fi
		fi
		if [[ $ID == "amzn" ]]; then
			OS="amzn"
			if [[ $VERSION_ID != "2" ]]; then
				echo "⚠️ Your version of Amazon Linux is not supported."
				echo ""
				echo "The script only support Amazon Linux 2."
				echo ""
				exit 1
			fi
		fi
	elif [[ -e /etc/arch-release ]]; then
		OS=arch
	else
		echo "Looks like you aren't running this installer on a Debian, Ubuntu, Fedora, CentOS, Amazon Linux 2, Oracle Linux 8 or Arch Linux system"
		exit 1
	fi
}

function initialCheck() {
	if ! isRoot; then
        messageError "Sorry, you need to run this as root"
	fi
	checkOS
}

function installDocker() {
    if [[ $OS =~ (debian|ubuntu) ]]; then
        apt-get update -y
        apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg \
            lsb-release
        curl -fsSL https://get.docker.com/gpg | apt-key add -
        apt-get update -y
    elif [[ $OS == 'centos' ]]; then
        messageWarning "function not implemented"
    elif [[ $OS == 'oracle' ]]; then
        messageWarning "function not implemented"
    elif [[ $OS == 'amzn' ]]; then
        messageWarning "function not implemented"
    elif [[ $OS == 'fedora' ]]; then
        messageWarning "function not implemented"
    elif [[ $OS == 'arch' ]]; then
        # Install required dependencies and upgrade the system
        messageWarning "function not implemented"
    fi

    curl -sSL https://get.docker.com | sh

	# Find out if the machine uses nogroup or nobody for the permissionless group
	if grep -qs "^nogroup:" /etc/group; then
		NOGROUP=nogroup
	else
		NOGROUP=nobody
	fi

	# Add group and permissions
	if [[ $OS == 'arch' || $OS == 'fedora' || $OS == 'centos' || $OS == 'oracle' ]]; then
        messageWarning "function not implemented"
	elif [[ $OS == "ubuntu" ]] && [[ $VERSION_ID == "16.04" ]]; then
        groupadd docker
        usermod -aG docker "${USER}"
	else
        groupadd docker
        usermod -aG docker "${USER}"
	fi

}

# Check for root, TUN, OS...
initialCheck

# Check if Docker is already installed
installDocker
