eval "$(/opt/homebrew/bin/brew shellenv)"

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Go
export GOPATH=$HOME/go
export GOROOT=/usr/local/go

# Android / mobile dev
export ANDROID_HOME=$HOME/Library/Android/sdk

export PATH="$PATH:/Users/ismith/.dotnet/tools"
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
[ -d "$ANDROID_HOME" ] && PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"
[ -d "$HOME/.fastlane/bin" ] && PATH="$PATH:$HOME/.fastlane/bin"
export PATH

# GNU grep, excluding common noise dirs
alias grep="ggrep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv}"

# Added by Obsidian
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
