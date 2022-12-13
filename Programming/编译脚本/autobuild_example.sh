#!/bin/bash
shell_path=$(cd "$(dirname "$0")";pwd)/
project=example_lib
version=1.0.0
full_version=v${version}-debug
src_path=${shell_path}../../../../src/
dst_path=${shell_path}../../../../../../../../Versions/Baselib/${project}/v${version}/linux/centos7.1/x64/

install_root_path=/home/install/
install_project_path=${install_root_path}${project}/
install_version_path=${install_project_path}${full_version}/

echo -e "\n\033[33m============= preparing =============\033[0m\n"

mkdir -p ${install_project_path}
rm -rf ${install_version_path}

echo -e "done!"
echo -e "\n\033[33m============= installing =============\033[0m\n"

cd ${src_path}
chmod +x configure
./configure --prefix=${install_version_path}

make clean && make V=1 -j$(nproc) && make install

echo -e "done!"
echo -e "\n\033[33m========== do some cleaning ==========\033[0m\n"

rm -rf ${dst_path}
mkdir -p ${dst_path}include
mkdir -p ${dst_path}lib

\cp -rf ${install_version_path}include/* ${dst_path}include/
\cp -rf ${install_version_path}lib/* ${dst_path}lib/

echo -e "done!"
echo -e "\n\033[33m========= install successful =========\033[0m\n"

echo -e "${project}-${full_version} has been installed on \033[33m${install_version_path}\033[0m"
echo -e "${project}-${full_version} has been copied to \033[33m${dst_path}\033[0m"