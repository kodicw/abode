{ pkgs, ... }:

let
  commonAliases = {
    ls = "eza";
    cat = "bat -p";
    cd = "z";
    grep = "rg";
    agy = "agy --dangerously-skip-permissions";
  };
in
{
  programs.nushell = {
    enable = true;
    shellAliases = commonAliases;
    configFile.text = ''
      $env.config = {
        show_banner: false
      }

      def --wrapped nvim [...rest] {
        with-env { VIMINIT: "set keyprotocol= | let &term=&term" } {
          ^nvim ...$rest
        }
      }

      if $nu.is-interactive {
          fastfetch
      }
    '';
  };

  home.packages = [ pkgs.xonsh ];

  home.file.".xonshrc".text = ''
    $UPDATE_OS_ENVIRON = True
    $XONSH_SHOW_DOT_CHAR = True

    aliases['ls'] = 'eza'
    aliases['cat'] = 'bat -p'
    aliases['cd'] = 'z'
    aliases['grep'] = 'rg'
    aliases['agy'] = 'agy --dangerously-skip-permissions'

    execx($(starship init xonsh))
    execx($(zoxide init xonsh))
    execx($(carapace _carapace xonsh))
    execx($(atuin init xonsh))
  '';

  programs.atuin = {
    enable = true;
    enableNushellIntegration = true;
    enableBashIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableNushellIntegration = true;
    enableBashIntegration = true;
  };

  programs.television = {
    enable = true;
    enableNushellIntegration = true;
    enableBashIntegration = true;
    channels = {
      files = {
        metadata = {
          name = "files";
        };
        source = {
          command = "fd --type f";
        };
        keybindings = {
          enter = "actions:open-nvim";
        };
        "actions.open-nvim" = {
          command = "nvim {}";
          mode = "execute";
        };
      };
    };
  };

  programs.bash = {
    enable = true;
    shellAliases = commonAliases // {
      nvim = "VIMINIT='set keyprotocol= | let &term=&term' nvim";
      ta = "tmux attach-session -t main 2>/dev/null || tmux new-session -s main";
    };
    initExtra = ''
      export GPG_TTY=$(tty)
      export PASSWORD_STORE_GPG_BINARY="gpg-pass"
      gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true

      # Auto-attach to persistent tmux session on interactive login if AUTO_ATTACH_TMUX is enabled
      if [[ $- == *i* ]] && [ -z "$TMUX" ] && [ -z "$ZELLIJ" ] && [ -z "$HERDR_ENV" ] && [ -z "$INSIDE_EMACS" ] && [ -z "$VSCODE_INJECTION" ]; then
        if [ "''${AUTO_ATTACH_TMUX:-0}" = "1" ] && command -v tmux >/dev/null 2>&1; then
          exec tmux attach-session -t main 2>/dev/null || exec tmux new-session -s main
        fi
      fi
    '';
  };

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    enableBashIntegration = true;
    settings = {
      format = ''
        [╭╴](238)$os$username$hostname$directory$git_branch$git_status$git_commit$rust$python$dotnet$kotlin$java$all $battery
        [╰─](238)$character '';

      add_newline = true;
    };
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
    enableBashIntegration = true;
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
    enableBashIntegration = true;
  };
}
