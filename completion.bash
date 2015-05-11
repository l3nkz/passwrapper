# bash completion for passwrapper

_pass_stores () {
    local stores=

    for d in ${PASS_HOME}/*; do
        if [ -d $d ]; then
            stores="${stores} $(basename $d)"
        fi
    done

    echo ${stores}
}&&
_lspass () {
    local cur=$1
    local opts="-h --help --passwords"

    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
}&&
_mkpass () {
    local cur=$1
    local opts="-h --help --with-key"

    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
}&&
_rmpass () {
    local cur=$1
    local opts="-h --help --quiet"

    COMPREPLY=( $(compgen -W "${opts} $(_pass_stores)" -- "${cur}") )
}&&
_passon () {
    local cur=$1
    local opts="-h --help"

    COMPREPLY=( $(compgen -W "${opts} $(_pass_stores)" -- "${cur}") )
}&&
_passoff () {
    local cur=$1
    local opts="-h --help"

    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
}&&
_passwrapper () {
    local cur prev words cword

    _init_completion || return

    case "${prev}" in
        lspass)
            _lspass ${cur}
            ;;
        mkpass)
            _mkpass ${cur}
            ;;
        rmpass)
            _rmpass ${cur}
            ;;
        passon)
            _passon ${cur}
            ;;
        passoff)
            _passoff ${cur}
            ;;
        *)
            return
            ;;
    esac
}&&
complete -o nospace -F _passwrapper lspass &&
complete -o nospace -F _passwrapper mkpass &&
complete -o nospace -F _passwrapper rmpass &&
complete -o nospace -F _passwrapper passon &&
complete -o nospace -F _passwrapper passoff
