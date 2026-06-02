#!/usr/bin/env bash
if [ -z "${BASH_VERSION:-}" ]; then
    exec bash "$0" "$@"
fi

shell_dir=$(
    cd "$(dirname "$0")" || exit
    pwd
)
shell_dir=$(realpath "${shell_dir}")

project=libmicrohttpd
version=1.0.1
full_version=v${version}-release

install_root_dir=/home/install
install_project_dir=${install_root_dir}/${project}
install_version_dir=${install_project_dir}/${full_version}

#$1: os version
os_version_default=centos7.1
os_version=
if [ -n "$1" ]; then
    os_version=$1
else
    if grep "Ubuntu" /etc/os-release; then
        os_version=ubuntu22.04
    elif grep "Kylin" /etc/os-release; then
        os_version=KylinV10
    elif grep "openEuler" /etc/os-release; then
        os_version=openeuler22.03
    else
        os_version=${os_version_default}
    fi
fi
echo -e "os_version=\033[34m${os_version}\033[0m"

#$2: os arch
os_arch_default=x64
os_arch=
if [ -n "$2" ]; then
    os_arch=$2
else
    uname_ret=$(uname -a)
    if [[ ${uname_ret} == *"x86_64"* ]]; then
        os_arch=x64
    elif [[ ${uname_ret} == *"aarch64"* ]]; then
        os_arch=aarch64
    else
        os_arch=${os_arch_default}
    fi
fi
echo -e "os_arch=\033[34m${os_arch}\033[0m"

src_dir=${shell_dir}/../../../../src

echo -e "\n\033[33m============= preparing =============\033[0m\n"

if [[ "${os_version}" == "centos7.1" ]]; then
    # switch to devtoolset-6
    gcc_version=$(gcc -dumpversion)
    gcc_major=${gcc_version%%.*}
    if [ "${gcc_major}" -le 4 ]; then
        if [ -r "/opt/rh/devtoolset-6/enable" ]; then
            source /opt/rh/devtoolset-6/enable
            echo -e "\033[34mswitch to devtoolset-6\033[0m"
        fi
    fi
fi

mkdir -p ${install_version_dir}
rm -rf ${install_version_dir}

echo -e "done!"
echo -e "\n\033[33m============= installing =============\033[0m\n"

cd "${src_dir}" || exit

autoreconf -f -i || {
    echo "autoreconf failed"
    exit 1
}

chmod +x configure
./configure \
    --prefix=${install_version_dir} \
    --enable-build-type=release \
    --enable-shared \
    --disable-static || {
    echo "configure failed"
    exit 1
}

make clean
make V=1 -j"$(nproc)" || {
    echo "make failed"
    exit 1
}
make install || {
    echo "make install failed"
    exit 1
}

echo -e "done!"
echo -e "\n\033[33m========== do some cleaning ==========\033[0m\n"

lib_dir=
if [ -d "${install_version_dir}/lib64" ]; then
    lib_dir=${install_version_dir}/lib64
elif [ -d "${install_version_dir}/lib" ]; then
    lib_dir=${install_version_dir}/lib
fi

if [ -n "${lib_dir}" ]; then
    cd ${lib_dir} || exit
    for src_file in *.so*; do
        if [ -f "${src_file}" ]; then
            dst_file=$(readlink "${src_file}")
            if [ -f "${dst_file}" ]; then
                rm -f "${src_file}"
            fi
        fi
    done
fi

echo -e "done!"
echo -e "\n\033[33m========= install successful =========\033[0m\n"

echo -e "${project}-${full_version} has been installed on \033[33m${install_version_dir}\033[0m"
