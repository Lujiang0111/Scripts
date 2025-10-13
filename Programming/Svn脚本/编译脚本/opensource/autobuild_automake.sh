#!/bin/bash
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

function CreateSoLinker() {
	cd "$1" || exit
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
}

openssl_include_dir=${shell_dir}/../../../../../../../../Versions/Baselib/openssl/v3.0.8/linux/${os_version}/${os_arch}/include
openssl_lib_dir=${shell_dir}/../../../../../../../../Versions/Baselib/openssl/v3.0.8/linux/${os_version}/${os_arch}/lib

CreateSoLinker "${openssl_lib_dir}"

mkdir -p ${install_project_dir}
rm -rf ${install_version_dir}

echo -e "done!"
echo -e "\n\033[33m============= installing =============\033[0m\n"

cd "${src_dir}" || exit

autoreconf -f

chmod +x configure
./configure \
	--prefix=${install_version_dir} \
	--enable-build-type=release \
	--enable-shared \
	--disable-static

make clean && make V=1 -j"$(nproc)" && make install

echo -e "done!"
echo -e "\n\033[33m========== do some cleaning ==========\033[0m\n"

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
