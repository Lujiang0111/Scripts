#!/usr/bin/env bash
if [ -z "${BASH_VERSION:-}" ]; then
    exec bash "$0" "$@"
fi

shell_dir=$(
    cd "$(dirname "$0")" || exit
    pwd
)
shell_dir=$(realpath "${shell_dir}")

project=srt
version=1.5.3
full_version=v${version}-release

install_root_dir=/home/install
install_project_dir=${install_root_dir}/${project}
install_version_dir=${install_project_dir}/${full_version}

os_release_file="/etc/os-release"
if [ ! -r "${os_release_file}" ]; then
    echo "can not read ${os_release_file}"
    exit 1
fi

os_version_default=centos7.1
os_version=
if grep "Ubuntu" ${os_release_file}; then
    os_version=ubuntu22.04
elif grep "Kylin" ${os_release_file}; then
    os_version=KylinV10
elif grep "openEuler" ${os_release_file}; then
    os_version=openeuler22.03
else
    os_version=${os_version_default}
fi
echo -e "os_version=\033[34m${os_version}\033[0m"

# get id and version_id form /etc/os-release
os_id=$(
    (
        . "${os_release_file}"
        printf '%s' "${ID:-}"
    )
)
os_version_id=$(
    (
        . "${os_release_file}"
        printf '%s' "${VERSION_ID:-}"
    )
)
echo -e "os_id=\033[34m${os_id}\033[0m,os_version_id=\033[34m${os_version_id}\033[0m"

#os arch
os_arch=
uname_ret=$(uname -a)
if [[ ${uname_ret} == *"x86_64"* ]]; then
    os_arch=x64
elif [[ ${uname_ret} == *"aarch64"* ]]; then
    os_arch=aarch64
else
    echo "unsupported os arch"
    exit 1
fi
echo -e "os_arch=\033[34m${os_arch}\033[0m"

src_dir=${shell_dir}/../../../../src

echo -e "\n\033[33m============= preparing =============\033[0m\n"

if [[ "${os_id}" == "centos" ]] && [[ "${os_version_id}" == "7" ]]; then
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

dep_dir=${shell_dir}/dep
rm -rf "${dep_dir}"
mkdir -p "${dep_dir}"

function PrepareSoDep() {
    mkdir -p "${dep_dir}/$1"
    if [ -d "$2/linux/${os_version}/${os_arch}" ]; then
        \cp -r "$2/linux/${os_version}/${os_arch}"/* "${dep_dir}/$1"
    elif [ -d "$2/linux/${os_version_default}/${os_arch}" ]; then
        \cp -r "$2/linux/${os_version_default}/${os_arch}"/* "${dep_dir}/$1"
    else
        echo -e "Could not find $1"
        return
    fi

    if [ -d "${dep_dir}/$1/lib" ]; then
        cd "${dep_dir}/$1/lib" || exit
        rm -rf ./*.a*
        for file in *.so.*; do
            if [ -f "${file}" ]; then
                realname=$(echo "${file}" | rev | cut -d '/' -f 1 | rev)
                libname=$(echo "${realname}" | cut -d '.' -f 1)
                if [ ! -f "${libname}".so ]; then
                    ln -sf "${realname}" "${libname}".so
                fi
            fi
        done
        cd - >/dev/null || exit
    fi
}

function PrepareADep() {
    mkdir -p "${dep_dir}/$1"
    if [ -d "$2/linux/${os_version}/${os_arch}" ]; then
        \cp -r "$2/linux/${os_version}/${os_arch}"/* "${dep_dir}/$1"
    elif [ -d "$2/linux/${os_version_default}/${os_arch}" ]; then
        \cp -r "$2/linux/${os_version_default}/${os_arch}"/* "${dep_dir}/$1"
    else
        echo -e "Could not find $1"
        return
    fi

    if [ -d "${dep_dir}/$1/lib" ]; then
        cd "${dep_dir}/$1/lib" || exit
        rm -rf ./*.so*
        cd - >/dev/null || exit
    fi
}

PrepareSoDep "openssl" "${shell_dir}/../../../../../../../../Versions/Baselib/openssl/v3.0.8"

export PKG_CONFIG_PATH=${dep_dir}/openssl/lib/pkgconfig:${PKG_CONFIG_PATH}

mkdir -p ${install_version_dir}
rm -rf ${install_version_dir}

echo -e "done!"
echo -e "\n\033[33m============= installing =============\033[0m\n"

cd "${src_dir}" || exit

chmod +x configure
./configure \
    --prefix=${install_version_dir} \
    --enable-shared \
    --disable-static \
    --enable-debug=0 \
    --use-openssl-pc=OFF \
    --openssl-include-dir="${dep_dir}/openssl/include" \
    --openssl-crypto-library="${dep_dir}/openssl/lib/libcrypto.so" \
    --openssl-ssl-library="${dep_dir}/openssl/lib/libssl.so" || {
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

rm -rf "${dep_dir}"

echo -e "done!"
echo -e "\n\033[33m========= install successful =========\033[0m\n"

echo -e "${project}-${full_version} has been installed on \033[33m${install_version_dir}\033[0m"
