# .bashrc
# set -o xtrace

#####################
# Bash initialization
#
# LOGIN:
# /etc/profile
# 	/etc/profile.env (if exists)
# 	/etc/bash/bashrc (if exists)
# 	/etc/profile.d/*.sh (if exists)
# 
# ~/.bash_profile
# 	/etc/bashrc
# 	~/.bashrc (if exists)
# if( ~/.bash_profile doesn't exist)
# 	~/.bash_login
#
# NON-LOGIN
# /etc/bash/bashrc
# ~/.bashrc

######################

set +o history
set -o emacs

if [[ -n ${COLODEBUG:-} && ${-} != *x* ]]; then
    :() {
        [[ ${1:--} != ::* ]] && return 0
        printf '%s\n' "${*}" >&2
    }
fi

host=${HOSTNAME:-`hostname`}
host=${host%%.*}
[[ "${host}" = "azlotek-mac" ]] && my_laptop=1 || my_laptop=0

if (( $my_laptop )); then
    : :: Running on laptop
    if [[ -x /opt/homebrew/bin/bash ]] && [[ $0 != /opt/homebrew/bin/bash ]]; then
	if [[ "$-" != "*i*" ]]; then
	    exec /opt/homebrew/bin/bash
	else
	    exec /opt/homebrew/bin/bash -li
	fi
    fi
fi

export TZ=EST5EDT
export LANG=C
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

if [[ "$-" = "*i*" ]]; then
    # Shell is non-interactive.
    set -o history
    return
fi

: :: Set up PATH
export PATH=$HOME/bin/:$PATH:/sbin:/usr/sbin:/usr/local/bin
[ -d $HOME/bin/`uname -s` ]            && export PATH=$HOME/bin/`uname -s`:$PATH
[ -d $HOME/bin/`uname -s`/`uname -p` ] && export PATH=$HOME/bin/`uname -s`/`uname -p`:$PATH
[ -d $HOME/.cargo/bin ]                && export PATH=$HOME/.cargo/bin:$PATH
[ -d $HOME/.local/bin ]                && export PATH=$HOME/.local/bin:$PATH
[ -d /opt/homebrew/bin ]               && export PATH=$PATH:/opt/homebrew/bin

if (( ! $my_laptop )); then
    [ -f /etc/skel/bashrc-DEFAULT ] && . /etc/skel/bashrc-DEFAULT
    [ -d /usr/lib64/openmpi/bin ]       && PATH=$PATH:/usr/lib64/openmpi/bin
    [ -d /usr/lib64/openmpi/lib ]       && export LD_LIBARY_PATH=/usr/lib64/openmpi/lib:$LD_LIBRARY_PATH
    [ -d /users/necast_shared/bin ]     && export PATH=$PATH:/users/necast_shared/bin
    
    clang_path=/scratch/clang+llvm-15.0.2-x86_64-unknown-linux-gnu/bin
    [ -d $clang_path ]			&& export PATH=$clang_path:$PATH
    unset clang_path
fi

shopt -s autocd cdspell checkhash cmdhist checkwinsize histappend no_empty_cmd_completion cdable_vars
export IGNOREEOF=1
unalias -a
umask 022

# if (( ! $my_laptop )); then
    
#     # set up ssh wrappers
#     [ -x $HOME/bin/myssh  ] && alias ssh=myssh
#     [ -x $HOME/bin/myscp  ] && alias scp=myscp
#     [ -x $HOME/bin/mysftp ] && alias sftp=mysftp
# fi

OS_TYPE=$(uname)
case ${OS_TYPE} in
    Darwin* | Linux|linux | Sun* | AIX*)
        [ -x $HOME/.bashrc.${OS_TYPE} ] && . $HOME/.bashrc.${OS_TYPE}
        ;;
esac

# [ -x /usr/local/packages/aime/install/run_as_root ] && alias rr=/usr/local/packages/aime/install/run_as_root

# # Pyenv environment variables
# export PYENV_ROOT="$HOME/.pyenv"
# export PATH="$PYENV_ROOT/bin:$PATH"
# # Pyenv initialization
# if command -v pyenv 1>/dev/null 2>&1; then
#   eval "$(pyenv init --path)"
# fi

if [[ ! -z ${ADE_VIEW_NAME} ]]; then
    unset http_proxy
    export ADE_BAD_SERVERS="server=/ade_autofs/ade_win /ade_autofs/ade3 /ade_autofs/ade99r"
    export ADE_MERGE_METHOD="-emerge"

    # NB: Be careful when using user_merge, it does not inherit all of
    #     our environment, in particular, $PATH.
    # export ADE_MERGE_METHOD="-user_merge"
    # export ADE_MERGE_TOOL=${HOME}/bin/emerge
    export ADE_DISABLE_MALWARE_CHECK_TRIGGER=1
    export CRASH_MODULE_PATH="$ORACLE_HOME/usm/src"
    export PATH=$PATH:$ORACLE_HOME/usm/utl
    export ADE_UMASK=022
    export ADE_CREATEVIEW_PERMISSIONS=0777
    export TKFV_DISKS_TYPE=file
    if [[ ${ADE_IN_CHROOT:-0} == 1 ]]; then
        [ -d $HOME/chroot.el8/bin ] && export PATH=$HOME/chroot.el8/bin:$PATH
    fi
fi
[[ -d $HOME/crash.extensions/`uname -p` ]] &&
    export CRASH_EXTENSIONS="/home/azlotek/crash.extensions/`uname -p`" ||
    export CRASH_EXTENSIONS="/home/azlotek/crash.extensions"
        
export ADE_CREATEVIEW_PERMISSIONS=0777

# Uniquify $PATH
temp_path=$( awk <<< $PATH -vRS=: -vORS= '!a[$0]++ {if (system("test -d " $1)==0) { if (ndir++ > 0) printf(":"); printf("%s", $0) }}' )
[[ ${temp_path} != "" ]] && export PATH=$temp_path

# bash completion
if (( $my_laptop )); then
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
	. $(brew --prefix)/etc/bash_completion
    fi
    [ -f ${HOME}/.iterm2_shell_integration.bash ] && . ${HOME}/.iterm2_shell_integration.bash
else
    [ -f /etc/profile.d/bash_completion.sh ]	  && . /etc/profile.d/bash_completion.sh
    [ -f $HOME/.bash_completion ]		  && . $HOME/.bash_completion
    [ -f ${HOME}/.iterm2_shell_integration.bash ] && . ${HOME}/.iterm2_shell_integration.bash
fi


export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export EDITOR=$HOME/bin/ec
export VIEWER=$HOME/bin/ecn
export VISUAL=$HOME/bin/ec

if (( ! $my_laptop )); then
    export TEST_VIEW=1
    # export USM_DIRS="oks/ cmds/ ofs/ avd/ afd/"
    # export USM_DIRS="oks/ cmds/ ofs/"
    export USM_INSPECT=no
    export USM_CODECHECKS=no
    export USM_CSCOPEDB=no
    export DONT_BUILD_CSCOPE=yes
    export USM_PARALLEL_BUILD=yes
    export OFS_REMASTER_SKIP_TOOLS_VERS=yes
    # export DO_NOT_SIGN=1
    export MAX_JOBS=10
    # aexport USM_PARFAIT=no

    #checking if we're running in Oracle Linux
    if [ -e /etc/oracle-release ]; then
        linuxdistro="ol"
        os_version=`/usr/bin/cut -d" " -f5 /etc/oracle-release|/usr/bin/cut -d"." -f1`

    #no, checking if we're running in SuseLinux
    elif [ -e /etc/SuSE-release ]; then
        linuxdistro="sles"
        os_version=`grep VERSION /etc/SuSE-release|/usr/bin/cut -d" " -f3|/usr/bin/cut -d"." -f1`
        os_spack=`grep PATCHLEVEL /etc/SuSE-release|/usr/bin/cut -d" " -f3`

    #no, checking if we're running in SuseLinux
    elif [[ -e /etc/os-release && $OS_NAME == "SLES" ]] ; then
        linuxdistro="sles"
        os_version=`grep VERSION_ID /etc/os-release|/usr/bin/cut -d"=" -f2|/usr/bin/cut -b 2,3`
        os_spack=`grep VERSION_ID /etc/os-release|/usr/bin/cut -d"=" -f2|/usr/bin/cut -b 5`

    #no, checking if we're running in RHEL
    elif [ -e /etc/redhat-release ]; then
        linuxdistro="rhel"
        xflavor=`/usr/bin/cut -d" " -f3 /etc/redhat-release`
        if [ "$xflavor" = "Enterprise" ]; then
            os_version=`/usr/bin/cut -d" " -f7 /etc/redhat-release|/usr/bin/cut -d"." -f1`
            linuxdistro="rhel"
        elif [ "$xflavor" = "Linux" ]; then
            os_version=`/usr/bin/cut -d" " -f5 /etc/redhat-release|/usr/bin/cut -d"." -f1`
            linuxdistro="el"
        fi

    else
        linuxdistro=""
        os_version=""
    fi
    os=${linuxdistro}$os_version
    [ -d $HOME/bin/`uname -s`/`uname -p`/${os} ] && export PATH=$HOME/bin/`uname -s`/`uname -p`/${os}:$PATH
fi

export PAGER=less
export LESS="-P?f%f .?m(file %i of %m) .?ltlines %lt-%lb?L/%L. .  byte %bB?s/%s. ?e(END) :?pB%pB\%..%t"
export INPUTRC=/etc/inputrc
export RLWRAP_HOME=$HOME/rlwrap
export MOSH_TITLE_NOPREFIX=1

case ${host} in
    #  Nashua
    azlotek-mac | \
    nsh*)
        export http_proxy=www-proxy-ash7.us.oracle.com:80
        export https_proxy=www-proxy-ash7.us.oracle.com:80
        ;;
    # Denver, Utah, Phoenix
    den*     | \
    stu*     | \
    usm*phx* | \
    stbm* )
        export http_proxy=www-proxy-brmdc.us.oracle.com:80
        export https_proxy=www-proxy-brmdc.us.oracle.com:80
        ;;
    # HQ
    rws* )
        export http_proxy=www-proxy-hqdc.us.oracle.com:80
        export https_proxy=www-proxy-hqdc.us.oracle.com:80
        ;;
    *)
        export http_proxy=www-proxy-ash7.us.oracle.com:80
        export https_proxy=www-proxy-ash7.us.oracle.com:80
        ;;
esac

export  HTTP_PROXY=${http_proxy}
export HTTPS_PROXY=${https_proxy}
export proxy_rsync=${http_proxy}
export PROXY_RSYNC=${http_proxy}
export   ftp_proxy=${http_proxy}
export   FTP_PROXY=${http_proxy}
export   all_proxy=${http_proxy}
export   ALL_PROXY=${http_proxy}

export auto_proxy=http://wpad.us.oracle.com/wpad.dat
export no_proxy=localhost,127.0.0.1,.us.oracle.com,.oraclecorp.com,.oraclevpn.com
export NO_PROXY=${no_proxy}

bash_prompt_command() {
    # How many characters of the $PWD should be kept
    local pwdmaxlen=20
    # Indicate that there has been dir truncation
    local trunc_symbol=".."
    local dir=${PWD##*/}
    pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))
    NEW_PWD=${PWD/#$HOME/\~}
    local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))
    if [ ${pwdoffset} -gt "0" ]
    then
        NEW_PWD=${NEW_PWD:$pwdoffset:$pwdmaxlen}
        NEW_PWD=${trunc_symbol}/${NEW_PWD#*/}
    fi
}
bash_prompt() {
    local NONE="\[\e[0m\]"    # reset color to term's fg color
   
    # regular colors
    local K="\[\e[0;30m\]"    # black
    local R="\[\e[0;31m\]"    # red
    local G="\[\e[0;32m\]"    # green
    local Y="\[\e[0;33m\]"    # yellow
    local B="\[\e[0;34m\]"    # blue
    local M="\[\e[0;35m\]"    # magenta
    local C="\[\e[0;36m\]"    # cyan
    local W="\[\e[0;37m\]"    # white
   
    # empahsized (bold) colors
    local EMK="\[\e[1;30m\]"
    local EMR="\[\e[1;31m\]"
    local EMG="\[\e[1;32m\]"
    local EMY="\[\e[1;33m\]"
    local EMB="\[\e[1;34m\]"
    local EMM="\[\e[1;35m\]"
    local EMC="\[\e[1;36m\]"
    local EMW="\[\e[1;37m\]"
   
    # background colors
    local BGK="\[\e[40m\]"
    local BGR="\[\e[41m\]"
    local BGG="\[\e[42m\]"
    local BGY="\[\e[43m\]"
    local BGB="\[\e[44m\]"
    local BGM="\[\e[45m\]"
    local BGC="\[\e[46m\]"
    local BGW="\[\e[47m\]"

    local BLINK="\[\e[5m\]"

    local UC=$C                 # user color
    local USERNAME=""
    [ $UID -eq "0" ] && UC=$R   # root color
    [ $UID -eq "0" ] && USERNAME="root@"

    local CHROOT=""
    if [[ $(uname) == "Linux" ]]; then
        root_inode=$(stat -c %i /);
        if [[ $root_inode -ne 2 && $root_inode -ne 128 ]]; then
           echo "chroot";
           CHROOT="(cr)"
        fi
    fi
   
    PS1="${EMK}[${UC}${USERNAME}${EMK}${UC}\h ${CHROOT}${M}\${NEW_PWD}${EMK}]${UC}\\$ ${NONE}"
    # without colors: PS1="[\u@\h \${NEW_PWD}]\\$ "
    # extra backslash in front of \$ to make bash colorize the prompt

    # Verbose output for set -x tracing
    export PS4='${BASH_SOURCE}:${LINENO} ${FUNCNAME[0]} [${SHLVL},${BASH_SUBSHELL},$?] '
}

if [ "$TERM" == "vt100" -o "$TERM" == "dumb" -o "$EMACS" == "t" ]; then
    export PS1="\h [\W]> "
else 
    PROMPT_COMMAND=bash_prompt_command
    bash_prompt
    unset bash_prompt
fi

# function e () {
#     # run e myfile.txt to edit over TRAMP from local emacs.
#     method=ssh
# #    fullpath=$(readlink -f $1)

#     if [[ ${1:0:1} == "/" ]] ; then
# 	fullpath=$1
#     else
# 	fullpath=`pwd`/$1
#     fi


#     if [[ -e $fullpath ]]; then
# 	if [[ $(ls -ld $fullpath | cut -d' ' -f5) -gt 65536 ]]; then
# 	    method=scp
# 	fi

#     fi

#     echo -n "remotemacs_--tramp=/$method:$(hostname):$fullpath"

#     # delete the line not to trigger again
#     sleep 1
#     echo -ne "\r\033[2K"
# }

# function ec () {
#     declare -r cwd=$(pwd)
#     declare -r server=${HOME}/.emacs.d/server/server
#     declare -r server_opt="--server-file=${server}"
#     declare method="scp"
#     declare fullpath arg alt_editor tramp_args="" params="" sudo=""
#     declare -a save_file save_mode

#     echo "this is alias! " $*

#     [[ -x ${HOME}/bin/emacs ]] &&
#         alt_editor="--alternate-editor=${HOME}/bin/emacs" ||
#             alt_editor="--alternate-editor=`which vi`"

#     while getopts "cns" arg; do
#         case $arg in
# 	    c) params+="--create-frame" ;;
# 	    n) params+="--no-wait" ;;
# 	    # s) sudo="|sudo:" ;;
# 	    s) [[ "$HOSTNAME" != "azlotek-mac" ]] &&
# 	           sudo="|sudo:" ||
# 		       sudo="/sudo::"
# 	       ;;
# 	    *) ;;
#         esac
#     done
#     shift $((OPTIND-1))

#     if [[ "$HOSTNAME" != "azlotek-mac" ]]; then
#         [[ ! -z ${sudo} ]] && method="ssh"
#         tramp_args="/${method}:${HOSTNAME}${sudo}:"
#     else
#         tramp_args="${sudo}"
#     fi

#     files=0
#     if [[ $(id --user) = "0" ]]; then
#         # For any temp files, make sure that $USER can read/write the
#         # files (ie, esp for command line editting)
#         for file in $*; do
# 	    real_file=$(realpath $file)
# 	    if [[ -e $real_file && ${real_file:0:4} == "/tmp" ]]; then
# 	        save_file[$i]=$file
# 	        # save_mode[$i]=$(ls -ld $file | awk '/^[-dsbclp]([-r][-w][-x]){3}[.+]?$/ 
#                 #                    {for(i=0;i<3;i++) {symbol=substr($1,2+i*3,3); sum=0; 
#                 #                    if (substr(symbol,1,1) == "r") sum+=4;
#                 #                    if (substr(symbol,2,1) == "w") sum+=2;
#                 #                    if (substr(symbol,3,1) == "x") sum+=1;
#                 #                    printf "%d",sum;}}')
# 	        # chmod o+rwx $file
# 	        save_mode[$files]=$(ls -ld $file | awk '{for(i=0;i<3;i++) {mode=substr($1, 2+i*3, 3); gsub("-","",mode); printf "%s=%s%s", substr("ugo", 1+i, 1), mode, substr(",, ", i+1, 1)}}')
#                 chmod o+rwx $file
#                 (( files++ ))
# 	    fi
#         done
#     fi

#     emacsclient --tramp=${tramp_args} ${alt_editor} ${server_opt} ${params} $*
#     rc=$?

#     while [[ $files > 0 ]]; do
#         (( files-- ))
#         chmod ${save_mode[$i]} ${save_file[$i]}
#     done
#     return $rc
# }
# alias ecn="ec -n"



if (( ! $my_laptop )); then
    function cdl() {
	dir=$1
	if [[ -z $dir ]]; then
            dir="."
	fi
	
	cd $(find $dir -maxdepth 1 -type d | grep  -v '^\.$' | xargs /bin/ls -1td | head -n1)
    }
    alias cdc="cdl /var/crash && crash vmcore"

    if [[ ! -z ${ADE_VIEW_NAME} ]]; then
	#
	# If usmk_linux.mk has not changed, then see about suppressing the
	# .ssh/known_hosts file updates.
	#
	_cksum=$(perl -ne '
        if ( $_ =~ /^\s*USMK_BUILD_SSH_OPT\s+\?=/ ) {
            print $_;
            $more = 1 if $_ =~ /\\\s*$/;
            next;
        }
        if ( $_ =~ /^\s*USMK_BUILD_SCP_OPT\s+\?=/ ) {
            print $_;
            $more = 1 if $_ =~ /\\\s*$/;
            next;
        }
        if ( defined($more) ) {
            undef $more;
            print $_;
            $more = 1 if $_ =~ /\\\s*$/;
            next;
        }
    ' ${ADE_VIEW_ROOT}/usm/src/usmk_linux.mk | cksum)
	if [[ "${_cksum}" = '3161227313 276' ]]; then
            export USMK_BUILD_SSH_OPT='-o StrictHostKeyChecking=no -o BatchMode=yes -o UserKnownHostsFile=/dev/null'
            export USMK_BUILD_SCP_OPT='-o StrictHostKeyChecking=no -o BatchMode=yes -o UserKnownHostsFile=/dev/null'
	else
            # echo 2>&1 ""
            # echo 2>&1 -e "\033[31;1m"
            # echo 2>&1 "USMK_BUILD_SSH_OPT and/or USMK_BUILD_SCP_OPT has changed"
            # echo 2>&1 ""
            # echo 2>&1 "See ${ADE_VIEW_ROOT}/usm/src/usmk_linux.mk"
            # echo 2>&1 ""
            # echo 2>&1 "Update ~/.bashrc with the new ssh options and then update"
            # echo 2>&1 "checksum: '${_cksum}'"
            # echo 2>&1 -e "\033[0m"
            # echo 2>&1 ""
            echo "" >/dev/null
	    #        (set -x; sleep 5)
	fi
	unset _cksum

	# Keep containers alive for 10 hours
	export CTR_USM_LIFETIME=$((10 * 60 * 60))
	#
	# Short circuit cscope build for "make all"
	#
	# if [[ "$(readlink -f $ORACLE_HOME/usm/utl/cscope.bin2)" != "/usr/bin/true" ]]; then
	#     cp2local $ORACLE_HOME/usm/utl/cscope.bin2
	#     rm -f $ORACLE_HOME/usm/utl/cscope.bin2
	#     ln -s /usr/bin/true $ORACLE_HOME/usm/utl/cscope.bin2
	# fi
    fi
fi

# function edit-clipboard () {
#     emacsclient --create-frame --eval '(progn (switch-to-buffer "*clipboard*") (local-set-key (kbd "C-x #") (lambda () (interactive) (clipboard-kill-region (point-min) (point-max)) (kill-buffer) (delete-frame))) (erase-buffer) (clipboard-yank) (select-frame-set-input-focus (selected-frame)))'
# }

function edit-clipboard () {
    emacsclient --create-frame --eval '(my/edit-clipboard)' >/dev/null
}

bind '"\e\e[D": backward-word'
bind '"\e\e[C": forward-word'
bind -x '"\C-x\C-x": edit-clipboard'

export HISTIGNORE="export:set:exit:[bf]g:%:shopt"
export HISTCONTROL=ignoredups
export HISTSIZE=32768
export HISTFILESIZE=32768

function iterm2_set_profile()
{
    echo -e "\033]50;SetProfile=$1\a"
}

send_command_to_every_pane() {
    for session in `tmux list-sessions -F '#S'`; do
        for window in `tmux list-windows -t $session -F '#P' | sort`; do
            for pane in `tmux list-panes -t $session:$window -F '#P' | sort`; do
                tmux send-keys -t "$session:$window.$pane" "$*" C-m
            done
        done
    done
}

# env_parallel() {
#     export parallel_bash_environment='() {
#        '"$(echo "shopt -s expand_aliases 2>/dev/null"; alias;typeset -p | grep -vFf <(readonly; echo GROUPS; echo FUNCNAME; echo DIRSTACK; echo _; echo PIPESTATUS; echo USERNAME) | grep -v BASH_;typeset -f)"'
#        }'
#      # Run as: env_parallel ...
#      `which parallel` "$@"
#      unset parallel_bash_environment
# }

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    *)            fzf "$@" ;;
  esac
}

[[ -e $HOME/.fzf-extras/fzf-extras.sh ]] && source $HOME/.fzf-extras/fzf-extras.sh

# . `which env_parallel.bash`

eval "$(zoxide init bash)"


unset OS_TYPE
unset my_laptop

# foo

# Local variables:
# mode: shell-script
# sh-basic-offset: 4
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: ts=4 sw=4 et filetype=shA
set -o history
