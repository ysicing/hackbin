#!/bin/bash 

set -e

base=${1:-./.release}

releasedir=$base
rm -fr $releasedir
mkdir -p $releasedir

get_localbin(){
    echo "copy local bin"
    cp -a local/* ${releasedir}
}

get_etcd(){
    local ETCD_VER=v3.3.8
    local GOOGLE_URL=https://storage.googleapis.com/etcd
    local GITHUB_URL=https://github.com/coreos/etcd/releases/download
    DOWNLOAD_URL=${GOOGLE_URL}

    rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
    rm -rf /tmp/test-etcd && mkdir -p /tmp/test-etcd

    curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
    tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/test-etcd --strip-components=1
    echo "copy etcd"
    cp /tmp/test-etcd/etcd*  ${releasedir}
    chmod +x ${releasedir}/etcd*
}

get_dockercompose(){
    local DC_VER=1.23.2
    curl -L https://github.com/docker/compose/releases/download/${DC_VER}/docker-compose-Linux-x86_64 -o ${releasedir}/docker-compose
    echo "download docker-compose ${DC_VER}"
    chmod +x ${releasedir}/docker-compose
}

get_calicoctl(){
    local CALICO_VER=v3.5.0
    curl -s -L https://github.com/projectcalico/calicoctl/releases/download/${CALICO_VER}/calicoctl-linux-amd64 -o ${releasedir}/calicoctl
    echo "download calicoctl ${CALICO_VER}"
    chmod +x ${releasedir}/calicoctl
}

get_ctop(){
    local CTOP_VER=0.7.2
    curl -s -L https://github.com/bcicen/ctop/releases/download/v${CTOP_VER}/ctop-${CTOP_VER}-linux-amd64 -o ${releasedir}/ctop
    echo "download ctop ${CTOP_VER}"
    chmod +x ${releasedir}/ctop
}

get_dry(){
    local DRY_VER=v0.9-beta.8
    curl -s -L https://github.com/moncho/dry/releases/download/${DRY_VER}/dry-linux-amd64 -o ${releasedir}/dry
    echo "download dry ${DRY_VER}"
    chmod +x ${releasedir}/dry
}

get_imgreg(){
    local REG_VER=v0.16.0
    local IMG_VER=v0.5.6
    curl -s -L https://github.com/genuinetools/reg/releases/download/${REG_VER}/reg-linux-amd64 -o ${releasedir}/reg
    curl -s -L https://github.com/genuinetools/img/releases/download/${IMG_VER}/img-linux-amd64 -o ${releasedir}/img
    echo "download img/reg tools"
    chmod +x ${releasedir}/reg
    chmod +x ${releasedir}/img
}

get_kubeprompt(){
    curl -s -L https://rainbond-pkg.oss-cn-shanghai.aliyuncs.com/util/kube-prompt -o ${releasedir}/kube-prompt
    chmod +x ${releasedir}/kube-prompt
}

download(){
    get_localbin
    get_etcd
    get_dockercompose
    get_calicoctl
    get_ctop
    get_dry
    get_imgreg
    get_kubeprompt
}

build(){
    cp Dockerfile ${releasedir}
    cd ${releasedir}
    tar zcf pkg.tgz `find . -maxdepth 1 | sed 1d`
    docker build -t spanda/pkg .
}

case $1 in
    *)
        download
        build
        echo "run <docker run --rm -v /usr/local/bin:/sysdir spanda/pkg tar zxf /pkg.tgz -C /sysdir> for install"
    ;;
esac