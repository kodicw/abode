{ pkgs, ... }:

{
  programs.nushell = {
    enable = true;
    shellAliases = {
      "cd" = "z";
      "cat" = "bat -p";
      "grep" = "rg";
    };
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
    shellAliases = {
      nvim = "VIMINIT='set keyprotocol= | let &term=&term' nvim";
      ls = "eza";
      cat = "bat -p";
      cd = "z";
    };
    initExtra = ''
      if [[ $- == *i* ]] && [[ $(ps -p $PPID -o comm=) != "xonsh" ]] && command -v xonsh >/dev/null; then
        exec xonsh
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
