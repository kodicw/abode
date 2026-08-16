{
  pkgs,
  polarbear,
  llm-agents,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  isAarch64 = system == "aarch64-linux";
in
{
  home.packages =
    with pkgs;
    [
      fd
      bat
      eza
      opencode-desktop
      ripgrep
      speedtest-rs
      rustup
      dust
      glow
      gcc
      gnumake
      python3
      nodejs_latest
      openssh
      fastfetch
      btop
      rclone
      mcp-nixos
      ollama
      opencode
      ouch
      nb
      obsidian
      openspec
      llm-agents.packages.${system}.antigravity-cli
      polarbear.packages.${system}.nixvim
      polarbear.packages.${system}.tools-ssh
      google-cloud-sdk
      dbus
    ]
    ++ lib.optionals (!isAarch64) [
      ghostty
    ]
    ++ lib.optionals isAarch64 [
      # GPG wrapper for pass in Crostini (PTYs are root-owned, pinentry can't prompt)
      # pass hardcodes GPG="gpg2", so we shadow gpg2 with this wrapper that
      # strips --batch and uses loopback pinentry so gpg prompts interactively
      (pkgs.symlinkJoin {
        name = "pass-gpg-wrapper";
        paths = [
          (pkgs.writeShellScriptBin "gpg2" ''
            args=()
            for arg in "$@"; do
              [[ "$arg" == "--batch" ]] && continue
              args+=("$arg")
            done
            exec ${pkgs.gnupg}/bin/gpg --pinentry-mode loopback "''${args[@]}"
          '')
        ];
        # Higher priority than gnupg's gpg2 in PATH
        meta.priority = 1;
      })
    ];
}
