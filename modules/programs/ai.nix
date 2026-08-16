{
  pkgs,
  lib,
  llm-agents,
  system,
  config,
  ...
}:

let
  isAarch64 = system == "aarch64-linux";
in

{
  home.packages =
    [
      pkgs.python3
      llm-agents.packages.${system}.antigravity-cli
      llm-agents.packages.${system}.herdr
    ]
    ++ lib.optionals isAarch64 [
      (pkgs.writeShellScriptBin "run-gdrive-mcp" ''
        set -euo pipefail
        SA_KEY_FILE=$(mktemp)
        trap 'rm -f "$SA_KEY_FILE"' EXIT
        ${pkgs.pass}/bin/pass show api/google/service_account_key > "$SA_KEY_FILE"
        export GOOGLE_APPLICATION_CREDENTIALS="$SA_KEY_FILE"
        exec ${pkgs.uv}/bin/uvx mcp-server-gdrive "$@"
      '')
    ];

  programs.antigravity = {
    enable = true;
  };
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      model = "opencode/big-pickle";
      autoshare = false;
      autoupdate = true;
      mcp = {
        nixos = {
          type = "local";
          command = [ "${pkgs.mcp-nixos}/bin/mcp-nixos" ];
          enabled = true;
        };
        context7 = {
          type = "local";
          command = [ "${pkgs.context7-mcp}/bin/context7-mcp" ];
          enabled = true;
        };
        filesystem = {
          type = "local";
          command = [
            "${pkgs.mcp-server-filesystem}/bin/mcp-server-filesystem"
            "${config.home.homeDirectory}"
          ];
          enabled = true;
        };
        git = {
          type = "local";
          command = [ "${pkgs.mcp-server-git}/bin/mcp-server-git" ];
          enabled = true;
        };
        sqlite = {
          type = "local";
          command = [ "${pkgs.mcp-server-memory}/bin/mcp-server-memory" ];
          enabled = true;
        };
        memory = {
          type = "local";
          command = [ "${pkgs.mcp-server-memory}/bin/mcp-server-memory" ];
          enabled = true;
        };
        # --- Tier 1 MCP additions (nixpkgs-native) ---
        github = {
          type = "local";
          command = [
            "${pkgs.github-mcp-server}/bin/github-mcp-server"
            "stdio"
          ];
          enabled = false;
        };
        terraform = {
          type = "local";
          command = [ "${pkgs.terraform-mcp-server}/bin/terraform-mcp-server" ];
          enabled = true;
        };
        sequential-thinking = {
          type = "local";
          command = [ "${pkgs.mcp-server-sequential-thinking}/bin/mcp-server-sequential-thinking" ];
          enabled = true;
        };
        # --- Tier 1 MCP additions (fallbacks for non-nixpkgs) ---
        postgres = {
          type = "local";
          command = [
            "${pkgs.uv}/bin/uvx"
            "postgres-mcp"
          ];
          enabled = false;
        };
        docker = {
          type = "local";
          command = [
            "${pkgs.uv}/bin/uvx"
            "mcp-server-docker"
          ];
          enabled = true;
        };
        ansible = {
          type = "local";
          command = [
            "${pkgs.nodejs}/bin/npx"
            "-y"
            "@ansible/ansible-mcp-server"
            "--stdio"
          ];
          enabled = true;
        };
        fetch = {
          type = "local";
          command = [
            "${pkgs.uv}/bin/uvx"
            "--with"
            "mcp<2"
            "mcp-server-fetch"
          ];
          enabled = true;
        };
        time = {
          type = "local";
          command = [
            "${pkgs.uv}/bin/uvx"
            "--with"
            "mcp<2"
            "mcp-server-time"
          ];
          enabled = true;
        };
      };
    };
    tui = {
      theme = "catppuccin-mocha";
    };
    web = {
      enable = false;
      extraArgs = [
        "--hostname"
        "100.92.94.4"
        "--port"
        "4096"
        "--mdns"
      ];
    };
  };

  programs.mcp = {
    enable = true;
    servers = {
      nixos = {
        command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
      };
      context7 = {
        command = "${pkgs.context7-mcp}/bin/context7-mcp";
      };
      filesystem = {
        command = "${pkgs.mcp-server-filesystem}/bin/mcp-server-filesystem";
        args = [ "${config.home.homeDirectory}" ];
      };
      git = {
        command = "${pkgs.mcp-server-git}/bin/mcp-server-git";
      };
      sqlite = {
        command = "${pkgs.mcp-server-memory}/bin/mcp-server-memory";
      };
      # --- Tier 1 MCP additions (nixpkgs-native) ---
      terraform = {
        command = "${pkgs.terraform-mcp-server}/bin/terraform-mcp-server";
      };
      sequential-thinking = {
        command = "${pkgs.mcp-server-sequential-thinking}/bin/mcp-server-sequential-thinking";
      };
      # --- Tier 1 MCP additions (fallbacks for non-nixpkgs) ---
      docker = {
        command = "${pkgs.uv}/bin/uvx";
        args = [ "mcp-server-docker" ];
      };
      ansible = {
        command = "${pkgs.nodejs}/bin/npx";
        args = [
          "-y"
          "@ansible/ansible-mcp-server"
          "--stdio"
        ];
      };
      fetch = {
        command = "${pkgs.uv}/bin/uvx";
        args = [
          "--with"
          "mcp<2"
          "mcp-server-fetch"
        ];
      };
      time = {
        command = "${pkgs.uv}/bin/uvx";
        args = [
          "--with"
          "mcp<2"
          "mcp-server-time"
        ];
      };
      # --- Google Drive MCP Integration (droid/Crostini only) ---
    } // lib.optionalAttrs isAarch64 {
      gdrive = {
        command = "${config.home.homeDirectory}/.nix-profile/bin/run-gdrive-mcp";
      };
    };
  };

  programs.uv.enable = true;
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      theme = "dark";
    };
  };
  programs.codex.enable = true;
  programs.pi-coding-agent = {
    enable = true;
    package = llm-agents.packages.${system}.pi;
    context = ''
      Environment: Home Manager managed Linux system utilizing Nix flakes.
      Guidelines:
      - Prefer Nix (`nix-shell`, Nix flakes, or Home Manager declarations) for managing tools and dependencies.
      - Do not pollute the global system or mutate paths outside of Nix and the project workspace.
    '';
    settings = {
      defaultProvider = "opencode-go";
      defaultModel = "deepseek-v4-flash";
      defaultThinkingLevel = "high";
      packages = [
        "npm:pi-mcp-adapter"
        "npm:pi-web-access"
        "npm:pi-subagents"
        "npm:@juicesharp/rpiv-ask-user-question"
        "npm:pi-lens"
      ];
    };
  };
}
