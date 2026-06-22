{ pkgs, ... }:

{
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
            "/home/charles/code"
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
        package = pkgs.mcp-nixos;
      };
      context7 = {
        package = pkgs.context7-mcp;
      };
      filesystem = {
        package = pkgs.mcp-server-filesystem;
        args = [ "/home/charles/code" ];
      };
      git = {
        package = pkgs.mcp-server-git;
      };
      sqlite = {
        package = pkgs.mcp-server-memory;
      };
    };
  };

  programs.uv.enable = true;
  programs.claude-code.enable = true;
}
