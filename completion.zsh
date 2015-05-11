#compdef lspass mkpass rmpass passon passoff


__get_stores () {
    local -a stores

    for d in ${PASS_HOME}/*; do
        if [ -d $d ]; then
            stores+=$(basename $d)
        fi
    done

    echo ${stores[@]}
}

_lspass () {
    _arguments \
        '(-h --help)'{-h,--help}'[Show help message]' \
        '--passwords[Also show passwords in the store]'
}

_mkpass () {
    _arguments \
        '(-h --help)'{-h,--help}'[Show help message]' \
        '--with-key[Also generate a PGP key for the password store]'
}

_rmpass () {
    _arguments \
        '(-h --help)'{-h,--help}'[Show help message]' \
        '--quiet[Do not ask any questions]'

    _values 'NAME' $(__get_stores)
}

_passon () {
    _arguments \
        '(-h --help)'{-h,--help}'[Show help message]'

    _values 'NAME' $(__get_stores)
}

_passoff () {
    _arguments \
        '(-h --help)'{-h,--help}'[Show help message]'
}

_passwrapper () {
    local ret=1
    _call_function ret _$service
    return $ret
}

_passwrapper "$@"
