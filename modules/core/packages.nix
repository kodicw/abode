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
      llm-agents.packages.${system}.pi
      llm-agents.packages.${system}.antigravity-cli
      xonsh
      polarbear.packages.${system}.nixvim
      polarbear.packages.${system}.tools-ssh
      # pi-voice extension dependencies
      whisper-cpp
      piper-tts
      espeak-ng
    ]
    ++ lib.optionals (!isAarch64) [
      ghostty
    ];
}
