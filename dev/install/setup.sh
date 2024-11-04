#!/bin/bash
#Install Latest Stable 1Panel Release

osCheck=`uname -a`
if [[ $osCheck =~ 'x86_64' ]];then
    architecture="amd64"
elif [[ $osCheck =~ 'arm64' ]] || [[ $osCheck =~ 'aarch64' ]];then
    architecture="arm64"
elif [[ $osCheck =~ 'armv7l' ]];then
    architecture="armv7"
elif [[ $osCheck =~ 'ppc64le' ]];then
    architecture="ppc64le"
elif [[ $osCheck =~ 's390x' ]];then
    architecture="s390x"
else
    echo "For the current architecture that is not supported, please refer to the official documentation and choose the supported system."
    exit 1
fi

if [[ ! ${INSTALL_MODE} ]];then
	INSTALL_MODE="stable"
else
    if [[ ${INSTALL_MODE} != "dev" && ${INSTALL_MODE} != "stable" ]];then
        echo "Please enter the correct installation mode (DEV or Stable)"
        exit 1
    fi
fi

VERSION=$(curl -s https://resource.fit2cloud.com/1panel/package/${INSTALL_MODE}/latest)
HASH_FILE_URL="https://resource.fit2cloud.com/1panel/package/${INSTALL_MODE}/${VERSION}/release/checksums.txt"

if [[ "x${VERSION}" == "x" ]];then
    echo "Get the latest version failed, please try again"
    exit 1
fi

package_file_name="nextweb-${VERSION}-linux-${architecture}.tar.gz"
package_download_url="https://resource.fit2cloud.com/1panel/package/${INSTALL_MODE}/${VERSION}/release/${package_file_name}"
expected_hash=$(curl -s "$HASH_FILE_URL" | grep "$package_file_name" | awk '{print $1}')

if [ -f ${package_file_name} ];then
    actual_hash=$(sha256sum "$package_file_name" | awk '{print $1}')
    if [[ "$expected_hash" == "$actual_hash" ]];then
        echo "The installation package already exists, skip download"
        rm -rf nextweb-${VERSION}-linux-${architecture}
        tar zxvf ${package_file_name}
        cd nextweb-${VERSION}-linux-${architecture}
        /bin/bash install-native.sh
        exit 0
    else
        echo "There are already installation bags, but the hash value is not the same"
        rm -f ${package_file_name}
    fi
fi

echo "Start download NextWeb ${VERSION} Edition online installation package"
echo "Installation package download address: ${package_download_url}"

curl -LOk -o ${package_file_name} ${package_download_url}
curl -sfL https://resource.fit2cloud.com/installation-log.sh | sh -s 1p install ${VERSION}
if [ ! -f ${package_file_name} ];then
	echo "The download and installation package failed, please try again."
	exit 1
fi

tar zxvf ${package_file_name}
if [ $? != 0 ];then
	echo "The download and installation package failed, please try again。"
	rm -f ${package_file_name}
	exit 1
fi
cd nextweb-${VERSION}-linux-${architecture}

/bin/bash install-native.sh
