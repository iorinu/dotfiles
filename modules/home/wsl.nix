{ pkgs, ... }:
{
  home.packages = [
    pkgs.blesh
    pkgs.herdr
    pkgs.peco
  ];

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

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
      # Add fish/zsh-style syntax highlighting while preserving later bindings.
      if [[ $- == *i* ]]; then
        source -- ${pkgs.blesh}/share/blesh/ble.sh --attach=none
      fi

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

      # Select a ghq repository with peco and change to it with Ctrl-x j.
      peco-src() {
        local query selected_dir
        query="''${READLINE_LINE:0:READLINE_POINT}"
        selected_dir=$(ghq list -p | peco --prompt="repositories >" --query="$query") || return
        if [ -n "$selected_dir" ]; then
          cd -- "$selected_dir" || return
          READLINE_LINE=
          READLINE_POINT=0
        fi
      }
      bind -x '"\C-xj": peco-src'

      # Retain the WSL-terminal working-directory notification.
      __wezterm_osc7() {
        printf '\e]7;file://%s%s\e\\' "''${HOSTNAME}" "''${PWD}"
      }
      PROMPT_COMMAND="__wezterm_osc7''${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

      if [[ ''${BLE_VERSION-} ]]; then
        # Match the macOS behavior: known commands are green, invalid input red.
        ble-face -s syntax_command fg=red
        ble-face -s syntax_error fg=red
        ble-face -s command_builtin_dot fg=green,bold
        ble-face -s command_builtin fg=green
        ble-face -s command_alias fg=green
        ble-face -s command_function fg=green
        ble-face -s command_file fg=green
        ble-face -s command_keyword fg=green
        ble-attach
      fi
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
