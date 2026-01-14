#!/bin/bash
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
	# switch to devtoolset-8
	gcc_version=$(gcc -dumpversion)
	gcc_major=${gcc_version%%.*}
	if [ "${gcc_major}" -le 4 ]; then
		source /opt/rh/devtoolset-8/enable
		echo -e "\033[34mswitch to devtoolset-8\033[0m"
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

mkdir -p ${install_project_dir}
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
	--openssl-ssl-library="${dep_dir}/openssl/lib/libssl.so"

make clean && make V=1 -j"$(nproc)" && make install

echo -e "done!"
echo -e "\n\033[33m========== do some cleaning ==========\033[0m\n"

# \cp -r "${dep_dir}"/*/lib/*.so* ${install_version_dir}/lib

cd ${install_version_dir}/lib || exit
for src_file in *.so*; do
	if [ -f "${src_file}" ]; then
		dst_file=$(readlink "${src_file}")
		if [ -f "${dst_file}" ]; then
			rm -f "${src_file}"
		fi
	fi
done

echo -e "done!"
echo -e "\n\033[33m========= install successful =========\033[0m\n"

echo -e "${project}-${full_version} has been installed on \033[33m${install_version_dir}\033[0m"
