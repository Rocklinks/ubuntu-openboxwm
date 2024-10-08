autoload -U colors && colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M%{$fg[red]%}] %{$fg[magenta]%}%~%{$reset_color%}$%b "

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

setopt SHARE_HISTORY

plugins=(
  git
  history
  parcellite
  zsh-completions
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
)

source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh

alias update="sudo apt update && sudo apt upgrade -y"
alias install="sudo apt install -y"
alias remove="sudo apt remove --purge -y"
alias search="sudo apt search"
alias dsearch="sudo apt-cache search"
alias c="clear"
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias yay="sudo apt-get install"
alias enable="sudo systemctl enable"
alias disable="sudo systemctl disable"
alias start="sudo systemctl start"
alias restart="sudo systemctl restart"
alias status="sudo systemctl status"
alias reinstall="sudo apt reinstall"




