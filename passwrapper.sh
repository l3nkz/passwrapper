#!/usr/bin/env sh
#
# passwrapper - Smoothly manage multiple password stores.
# Copyright © 2015 Till Smejkal <till.smejkal+passwrapper@ossmail.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

passwrapper_initialize() {
    pass_home=$PASS_HOME
    EC=0

    if [ "$pass_home" = "" ]; then
        # Use the default
        pass_home=$HOME/.pass
    fi

    # Check if the directory is set up correctly
    if [ ! -d ${pass_home}/ ]; then
        mkdir -p ${pass_home}
        EC=$?
    fi

    export PASS_HOME=${pass_home}

    return ${EC}
}

lspass() {
    printf "Available password stores:\n"
    for f in ${PASS_HOME}/*; do
        if [ -d $f ]; then
            printf "%s\n" $(basename $f)
        fi
    done
}

mkpass() {
    local name=$1
    local pass_path=${PASS_HOME}/${name}

    if [ -e ${pass_path} ]; then
        printf "Password store %s exists already.\n" ${name}
        return 1
    fi

    # Create the new password store
    mkdir -p ${pass_path}
}

rmpass() {
    local name=$1
    local pass_path=${PASS_HOME}/${name}

    if [ ! -e ${pass_path} ]; then
        printf "Password store %s does not exist.\n" ${name}
        return 1
    fi

    printf "Every password stored in %s will be lost.\n" ${name}
    printf "Are you sure you want to remove? [y/N] "
    read response

    case "${response}" in
        [yY])
            # Remove the corresponding password store
            rm -rf ${pass_path}

            # If the just removed password store was currently active also
            # deactivate it.
            if [ ${pass_path} = ${PASS_DIR} ];
                passof
            fi

            ;;
        [nN]|*)
            return 1
            ;;
    esac
}

passon() {
    local name=$1
    local pass_path=${PASS_HOME}/${name}

    if [ ! -e ${pass_path} ]; then
        printf "Password store %s does not exist.\n" ${name}
        return 1
    fi

    export PASSWORD_STORE_DIR=${pass_path}
    export PASS_DIR=${pass_path}
}

passoff() {
    unset PASSWORD_STORE_DIR
    unset PASS_DIR
}

# Initialize passwrapper
passwrapper_initialize
