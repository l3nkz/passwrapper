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
    local pass_home=$PASS_HOME
    local EC=0

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

passwrapper_lspass_help() {
    printf "lspass [OPTIONS]\n"
    printf "  Show all password stores available.\n\n"
    printf "Options:\n"
    printf "  -h, --help        Show this help message\n"
    printf "      --passwords   Also show all passwords in the stores\n"
}

lspass() {
    # Parse the given arguments
    local show_passwords=0

    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                passwrapper_lspass_help
                return 0
                ;;
            --passwords)
                show_passwords=1
                ;;
            *)
                printf "Unknown option: %s\n\n" $1
                passwrapper_lspass_help
                return 1
                ;;
        esac

        shift
    done

    for f in ${PASS_HOME}/*; do
        if [ -d $f ]; then
            if [ $show_passwords -eq 1 ]; then
                printf "%s:\n" $(basename $f)
                (PASSWORD_STORE_DIR=$f pass ls)
                printf "\n"
            else
                printf "%s\n" $(basename $f)
            fi
        fi
    done
}

passwrapper_mkpass_help() {
    printf "mkpass [OPTIONS] NAME\n"
    printf "  Create a new password store with the name NAME.\n\n"
    printf "Options:\n"
    printf "  -h, --help        Show this help message\n"
    printf "      --with-key    Also generate a new PGP-Key for\n"
    printf "                    the password store\n"
}

mkpass() {
    # Parse the given arguments
    local generate_key=0
    local name=

    if [ $# -lt 1 ]; then
        passwrapper_mkpass_help
        return 1
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                passwrapper_mkpass_help
                return 0
                ;;
            --with-key)
                generate_key=1
                ;;
            *)
                if [ -z "$name" ]; then
                    name=$1
                else
                    printf "Unknown option: %s\n\n" $1
                    passwrapper_mkpass_help
                    return 1;
                fi
                ;;
        esac

        shift
    done
    
    local pass_path=${PASS_HOME}/${name}

    if [ -e ${pass_path} ]; then
        printf "Password store %s exists already.\n" ${name}
        return 1
    fi

    # Create the new password store
    mkdir -p ${pass_path}

    # If specified also create the PGP key
    if [ ${generate_key} -eq 1 ]; then
        gpg --full-gen-key
    fi
}

passwrapper_rmpass_help() {
    printf "rmpass [OPTIONS] NAME\n"
    printf "  Remove the password store with the name NAME.\n\n"
    printf "Options:\n"
    printf "  -h, --help        Show this help message\n"
    printf "      --quiet       Do not ask any questions\n"
}

rmpass() {
    # Parse the given arguments
    local name=
    local quiet=0

    if [ $# -lt 1 ]; then
        passwrapper_rmpass_help
        return 1
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                passwrapper_rmpass_help
                return 0
                ;;
            --quiet)
                quiet=1
                ;;
            *)
                if [ -z "$name" ]; then
                    name=$1
                else
                    printf "Unknown option: %s\n\n" $1
                    passwrapper_rmpass_help
                    return 1
                fi
                ;;
        esac

        shift
    done

    local pass_path=${PASS_HOME}/${name}

    if [ ! -e ${pass_path} ]; then
        printf "Password store %s does not exist.\n" ${name}
        return 1
    fi

    if [ $quiet -eq 0 ]; then
        printf "Every password stored in %s will be lost.\n" ${name}
        printf "Are you sure you want to remove? [y/N] "
        read response

        case "${response}" in
            [yY])
                ;;
            [nN]|*)
                return 0
                ;;
        esac
    fi

    # Remove the corresponding password store
    rm -rf ${pass_path}

    # If the just removed password store was currently active also
    # deactivate it.
    if [ "${pass_path}" = "${PASS_DIR}" ]; then
        passoff
    fi
}

passwrapper_passon_help() {
    printf "passon [OPTIONS] NAME\n"
    printf "  Activate the password store with the name NAME.\n\n"
    printf "Options:\n"
    printf "  -h, --help        Show this help message\n"
}

passon() {
    # Parse the given arguments
    local name=

    if [ $# -lt 1 ]; then
        passwrapper_passon_help
        return 1
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                passwrapper_passon_help
                return 0
                ;;
            *)
                if [ -z "$name" ]; then
                    name=$1
                else
                    printf "Unknown option: %s\n\n" $1
                    passwrapper_passon_help
                    return 1
                fi
                ;;
        esac

        shift
    done


    local pass_path=${PASS_HOME}/${name}

    if [ ! -e ${pass_path} ]; then
        printf "Password store %s does not exist.\n" ${name}
        return 1
    fi

    export PASSWORD_STORE_DIR=${pass_path}
    export PASS_DIR=${pass_path}
}

passwrapper_passoff_help() {
    printf "passoff [OPTIONS]\n"
    printf "  Deactivate the password stores.\n\n"
    printf "Options:\n"
    printf "  -h, --help        Show this help message\n"

}

passoff() {
    # Parse the given arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                passwrapper_passoff_help
                return 0
                ;;
            *)
                printf "Unknown option: %s\n\n" $1
                passwrapper_passoff_help
                return 1
                ;;
        esac

        shift
    done

    unset PASSWORD_STORE_DIR
    unset PASS_DIR
}

# Initialize passwrapper
passwrapper_initialize
