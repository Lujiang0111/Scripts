#!/bin/bash
shell_path=$(
	cd "$(dirname "$0")" || exit
	pwd
)/
project=example_lib
version=1.0.0
full_version=v${version}-release
os_version=centos7.1
os_arch=x64
src_path=${shell_path}../../../../src/
dst_path=${shell_path}../../../../../../../../Versions/Baselib/${project}/v${version}/linux/${os_version}/${os_arch}/

install_root_path=/home/install/
install_project_path=${install_root_path}${project}/
install_version_path=${install_project_path}${full_version}/

echo -e "\n\033[33m============= preparing =============\033[0m\n"

function DelAFile() {
	cd "$1" || exit
	for file in *.a*; do
		if [ -f "${file}" ]; then
			rm -rf "${file}"
		fi
	done
	cd - >/dev/null || exit
}

function DelSoFile() {
	cd "$1" || exit
	for file in *.so*; do
		if [ -f "${file}" ]; then
			rm -rf "${file}"
		fi
	done
	cd - >/dev/null || exit
}

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

mkdir -p ${install_project_path}
rm -rf ${install_version_path}

echo -e "done!"
echo -e "\n\033[33m============= installing =============\033[0m\n"

cd "${src_path}" || exit
chmod +x configure
./configure --prefix=${install_version_path}

make clean && make V=1 -j"$(nproc)" && make install

echo -e "done!"
echo -e "\n\033[33m========== do some cleaning ==========\033[0m\n"

rm -rf "${dst_path}"
mkdir -p "${dst_path}"include
mkdir -p "${dst_path}"lib

\cp -rf ${install_version_path}include/* "${dst_path}"include/
\cp -rf ${install_version_path}lib/* "${dst_path}"lib/

cd "${dst_path}"lib/ || exit
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

echo -e "${project}-${full_version} has been installed on \033[33m${install_version_path}\033[0m"
echo -e "${project}-${full_version} has been copied to \033[33m${dst_path}\033[0m"
