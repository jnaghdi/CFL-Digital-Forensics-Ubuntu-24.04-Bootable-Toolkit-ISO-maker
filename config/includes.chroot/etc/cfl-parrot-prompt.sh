# CFL Forensics - Parrot 7.3 "Echo" style shell prompt.
# Sourced at the end of ~/.bashrc for every interactive bash shell.
#
# Layout (matches Parrot's bashrc):
#   ┌─[✗]─[root@host]─[/current/dir]
#   └──╼ #
# Brackets red; "root" bright red (plain white for non-root users);
# "@" yellow; host bright cyan; working directory green; symbol yellow.
# A red [✗] segment appears after a failed command.

if [ -n "${BASH_VERSION:-}" ]; then
    case $- in
        *i*) : ;;          # interactive: restyle below
        *) return 0 2>/dev/null || exit 0 ;;
    esac

    PS1="\[\033[0;31m\]\342\224\214\342\224\200\$([[ \$? != 0 ]] && echo \"[\[\033[0;31m\]\342\234\227\[\033[0;37m\]]\342\224\200\")[$(if [[ ${EUID} == 0 ]]; then echo '\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;96m\]\h'; else echo '\[\033[0;39m\]\u\[\033[01;33m\]@\[\033[01;96m\]\h'; fi)\[\033[0;31m\]]\342\224\200[\[\033[0;32m\]\w\[\033[0;31m\]]\n\[\033[0;31m\]\342\224\224\342\224\200\342\224\200\342\225\274 \[\033[0m\]\[\033[01;33m\]\\$\[\033[0m\] "
    export PS1
fi
