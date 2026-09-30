{ pkgs, ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      egrep = "egrep --color=auto";
      fgrep = "fgrep --color=auto";
      grep = "grep --color=auto";
      l = "ls -CF";
      la = "ls -A";
      ll = "ls -alF";
      ls = "ls --color=auto";
      venvin = "source ~/venv/bin/activate";
      venvout = "deactivate";
    };
    bashrcExtra = ''
      # Preserve Ubuntu's system prompt, sudo hint, and command-not-found handler.
      if [ -r /etc/bash.bashrc ]; then
        . /etc/bash.bashrc
      fi

      # Keep existing WSL development-tool integrations when installed.
      if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      fi
      if [ -r "$HOME/.cargo/env" ]; then
        . "$HOME/.cargo/env"
      fi
      if [ -r "$HOME/.fzf.bash" ]; then
        . "$HOME/.fzf.bash"
      fi
      if [ -x /usr/local/cuda/bin/nvcc ]; then
        export CUDA_HOME=/usr/local/cuda
        export PATH="$CUDA_HOME/bin:$PATH"
        export LD_LIBRARY_PATH="$CUDA_HOME/lib64''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      fi

      alert() {
        local command_status=$?
        local last_command
        last_command=$(history 1 | sed -E 's/^ *[0-9]+ *//; s/[;&|] *alert$//')
        notify-send --urgency=low -i "$([ "$command_status" -eq 0 ] && echo terminal || echo error)" "$last_command"
      }

      # Retain the WSL-terminal working-directory notification.
      __wezterm_osc7() {
        printf '\e]7;file://%s%s\e\\' "''${HOSTNAME}" "''${PWD}"
      }
      PROMPT_COMMAND="__wezterm_osc7''${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
    '';
  };

  programs.zsh = {
    enable = true;
    initContent = ''
      export PATH="$HOME/go/bin:$PATH"
    '';
  };

  # Keep the installer-managed profile; Home Manager owns the interactive rc files.
  home.file.".profile".enable = false;
  # Let Bash fall back to .profile, which already sources .bashrc.
  home.file.".bash_profile".enable = false;

  nix.package = pkgs.nix;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  targets.genericLinux = {
    enable = true;
    gpu.enable = false;
  };
}
