# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="afowler"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	sudo
	git
	command-not-found
	zsh-syntax-highlighting
	zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh
#source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
#source /usr/share/zsh/plugins/zsh-syntax-highlighting
#source /usr/share/zsh/plugins/zsh-autosuggestions

# configure key keybindings
bindkey -e                                        # emacs key bindings
bindkey '^U' backward-kill-line                   # ctrl + U
bindkey '^[[3~' delete-char                       # delete
bindkey '^[[1;3C' forward-word                    # alt + ->
bindkey '^[[1;3D' backward-word                   # alt + <-
bindkey '^[[H' beginning-of-line                  # home
bindkey '^[[F' end-of-line                        # end

# Enable completion features
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# History configurations
HISTFILE=~/.zsh_history
HISTSIZE=2000
SAVEHIST=2000

# Manual aliases
alias ll='/usr/bin/lsd -lh --group-dirs=first'
alias la='/usr/bin/lsd -a --group-dirs=first'
alias l='/usr/bin/lsd --group-dirs=first'
alias lla='/usr/bin/lsd -lha --group-dirs=first'
alias ls='/usr/bin/lsd --group-dirs=first'
alias cat='/usr/bin/bat'
alias catn='/usr/bin/cat'
alias catnl='/usr/bin/bat --paging=never'
alias icat='kitten icat'
alias tra='noglob tra'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gl='git log --oneline'
alias gb='git checkout -b'
alias gd='git diff'
alias c='clear'
alias x="exit"
alias reloadshell="source ~/.zshrc"
alias editshell="nano ~/.zshrc"
alias editterm="nano ~/.config/kitty/kitty.conf"
alias h='history'

# Functions
function dir_icon {
	if [[ "$PWD" == "$HOME" ]]; then
		echo "%B%F{black}%f%b"
	else
		echo "%B%F{cyan}%f%b"
	fi
}

function parse_git_branch {
	local branch
	branch=$(git symbolic-ref --short HEAD 2> /dev/null)
	if [ -n "$branch" ]; then
		echo " [$branch]"
	fi
}

PROMPT='%F{cyan}󰣇 %f %F{magenta}%n%f $(dir_icon) %F{red}%~%f%${vcs_info_msg_0_} %F{yellow}$(parse_git_branch)%f %(?.%B%F{green}.%F{red})%f%b '

# Custom functions

# Buscar proceso y matarlo

function pk() {
  if [ -z "$1" ]; then
    echo "Uso: $0 <nombre_proceso> [--kill, -k]"
    return 1
  fi

  pid=$(pgrep -i "$1")

  if [ -z "$pid" ]; then
    echo "No se encontró ningún proceso con el nombre '$1'."
    return 1
  else
    echo "PID del proceso '$1': $pid"
  fi

  if [ "$2" = "--kill" ] || [ "$2" = "-k" ]; then
    kill "$pid"
    if [ $? -eq 0 ]; then
      echo "Proceso '$1' (PID: $pid) terminado."
    else
      echo "No se pudo terminar el proceso '$1'."
    fi
  fi
}

# -- Descargar musica de yt en alta calidad -- #

function ytmusic(){
	if [ $# -lt 1 ]; then
		echo "Usa: ${FUNCNAME[0]} <youtube url> [carpeta]"
		return
	fi

	if [ $# -eq 2 ]; then	
        mkdir -p "$2"
        yt-dlp --audio-quality --audio-format --extract-audio -x -f bestaudio -o "$2/%(title)s.%(ext)s" "$1"
    else
        yt-dlp --audio-quality --audio-format --extract-audio -x -f bestaudio -x -o "%(title)s.%(ext)s" "$1"
    fi
}

# -- Descargar videos de yt en alta calidad -- #


function ytvideo(){
    if [ $# -lt 1 ]; then
        echo "Usa: ${FUNCNAME[0]} <youtube url> [carpeta]"
        return
    fi

    if [ $# -eq 2 ]; then
        mkdir -p "$2"
        yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 -o "$2/%(title)s.%(ext)s" "$1"
    else
        yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 -o "%(title)s.%(ext)s" "$1"
    fi
}

## -- Buscar un comando en el historial -- #

function hs() {
    history | grep "$1";
}

# mejora para fzf
function fzf-lovely(){

	if [ "$1" = "h" ]; then
		fzf -m --reverse --preview-window down:20 --preview '[[ $(file --mime {}) =~ binary ]] &&
 	                echo {} is a binary file ||
	                 (batcat --style=numbers --color=always {} ||
	                  highlight -O ansi -l {} ||
	                  coderay {} ||
	                  rougify {} ||
	                  cat {}) 2> /dev/null | head -500'

	else
	        fzf -m --preview '[[ $(file --mime {}) =~ binary ]] &&
	                         echo {} is a binary file ||
	                         (batcat --style=numbers --color=always {} ||
	                          highlight -O ansi -l {} ||
	                          coderay {} ||
	                          rougify {} ||
	                          cat {}) 2> /dev/null | head -500'
	fi
}


function vpn-on(){
	sudo wg-quick up /etc/wireguard/Alex.conf
}

function vpn-off(){
	sudo wg-quick down /etc/wireguard/Alex.conf
}

function tra() {
	if [ $# -lt 1 ]; then
    		echo "Usa: $funcstack[1] <frase>"
    		return
	fi
	
	echo -e "Texto original:\n$*"
	
	echo -e "\nTraducción:\n"
	trans -b :es "$*"	

}

#export PYENV_ROOT="$HOME/.pyenv"
#[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
#eval "$(pyenv init --path)"
#eval "$(pyenv init -)"
#eval "$(pyenv virtualenv-init -)"
