#-------------------------------------------------------------------------------
# SSH Agent
#-------------------------------------------------------------------------------
function __ssh_agent_is_started -d "check if ssh agent is already started"
	if begin; test -f $SSH_ENV; and test -z "$SSH_AGENT_PID"; end
		source $SSH_ENV > /dev/null
	end

	if test -z "$SSH_AGENT_PID"
		return 1
	end

	ssh-add -l > /dev/null 2>&1
	if test $status -eq 2
		return 1
	end
end

function __ssh_agent_start -d "start a new ssh agent"
  ssh-agent -c | sed 's/^echo/#echo/' > $SSH_ENV
  chmod 600 $SSH_ENV
  source $SSH_ENV > /dev/null
  ssh-add
end

if not test -d $HOME/.ssh
    mkdir -p $HOME/.ssh
    chmod 0700 $HOME/.ssh
end

if test -d $HOME/.gnupg
    chmod 0700 $HOME/.gnupg
end

if test -z "$SSH_ENV"
    set -xg SSH_ENV $HOME/.ssh/environment
end

if not __ssh_agent_is_started
    __ssh_agent_start
end

# Editor
set -gx EDITOR nvim

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------
# Shortcut to setup a nix-shell with fish. This lets you do something like
# `fnix -p ghc` to get an environment with ghc but use the fish shell along
# with it.
alias fnix "nix-shell --run fish"
