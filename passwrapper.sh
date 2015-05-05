#!/usr/bin/env sh

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
