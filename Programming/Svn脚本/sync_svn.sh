#!/bin/sh
shell_dir=$(
    cd "$(dirname "$0")" || exit
    pwd
)
shell_dir=$(realpath "${shell_dir}")

# Enter manually
svn_username=
svn_password=
svn_checkout_url=svn://xxx/xxx

svn_checkout_url=${svn_checkout_url%/}
svn_checkout_dir=${svn_checkout_url##*/}

if [ -n "${svn_username}" ] && [ -n "${svn_password}" ]; then
    svn_auth_code="--non-interactive --trust-server-cert --username ${svn_username} --password ${svn_password}"
else
    svn_auth_code=
fi

cd "${shell_dir}" || exit
if svn info . >/dev/null 2>&1; then
    curr_svn_url=$(svn info . 2>/dev/null | sed -n 's/^URL: //p')
    echo "svn sync ${curr_svn_url}"

    #rm ./* -rf
    svn revert -R .
    # shellcheck disable=SC2086
    svn up ${svn_auth_code}
else
    echo "Clear and checkout ${svn_checkout_url} to ${svn_checkout_dir}"

    rm "${svn_checkout_dir}" -rf
    # shellcheck disable=SC2086
    svn checkout "${svn_checkout_url}" "${svn_checkout_dir}" ${svn_auth_code}
fi
