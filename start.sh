#!/usr/bin/env bash

if [ "${uid}" -a "${gid}" ] ; then
    set -e
    user_name=$(basename ${HOME})
    if (( 1000 != ${gid} )) ; then
        groupadd --gid ${gid} ${user_name}
    fi
    if (( 1000 != ${uid} )) ; then
        useradd \
            --home-dir "$HOME" \
            --uid ${uid} \
            --gid ${gid} \
            --groups sudo \
            ${user_name}
    fi
    if ((1000 != ${uid} || 1000 != ${gid} )) ; then
        chown ${uid}:${gid} $HOME
        chown ${uid}:${gid} $HOME/.ssh
    fi
    su_cmd="sudo --preserve-env --user ${user_name}"
    set +e
fi

if (( $# == 0 )); then
    set sdf-e
	${su_cmd} /bin/bash
else
    set -e
	${su_cmd} "$@"
fi
