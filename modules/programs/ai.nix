{
  pkgs,
  llm-agents,
  system,
  config,
  ...
}:

{
  home.packages = [
    pkgs.python3
    llm-agents.packages.${system}.antigravity-cli
    llm-agents.packages.${system}.herdr
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
        playwright = {
          type = "local";
          command = [ "${pkgs.playwright-mcp}/bin/playwright-mcp" ];
          enabled = true;
        };
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
      playwright = {
        command = "${pkgs.playwright-mcp}/bin/playwright-mcp";
      };
      # github = {
      #   command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
      #   args = [ "stdio" ];
      # };
      terraform = {
        command = "${pkgs.terraform-mcp-server}/bin/terraform-mcp-server";
      };
      sequential-thinking = {
        command = "${pkgs.mcp-server-sequential-thinking}/bin/mcp-server-sequential-thinking";
      };
      # --- Tier 1 MCP additions (fallbacks for non-nixpkgs) ---
      # postgres = {
      #   command = "${pkgs.uv}/bin/uvx";
      #   args = [ "postgres-mcp" ];
      # };
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
    settings = {
      defaultProvider = "opencode-go";
      defaultModel = "deepseek-v4-flash";
      defaultThinkingLevel = "high";
      packages = [
        "git:github.com/kodicw/pi-voice"
      ];
    };
  };
}
