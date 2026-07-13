#!/usr/bin/env bash
if [ -z "${BASH_VERSION:-}" ]; then
    exec bash "$0" "$@"
fi

shell_dir=$(
    cd "$(dirname "$0")" || exit
    pwd
)
shell_dir=$(realpath "${shell_dir}")

project=opencv
version=4.11.0
full_version=v${version}-release

install_root_dir=/home/install
install_project_dir=${install_root_dir}/${project}
install_version_dir=${install_project_dir}/${full_version}

os_release_file="/etc/os-release"
if [ ! -r "${os_release_file}" ]; then
    echo "can not read ${os_release_file}"
    exit 1
fi

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

mkdir -p ${install_version_dir}
rm -rf ${install_version_dir}

echo -e "done!"
echo -e "\n\033[33m============= installing =============\033[0m\n"

cd "${src_dir}" || exit
build_dir="build"/"${os_id}""${os_version_id}"
rm -rf "${build_dir}"
mkdir -p "${build_dir}"

cd "${build_dir}" || exit
cmake -DCMAKE_INSTALL_PREFIX=${install_version_dir} ../.. || {
    echo "cmake failed"
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
