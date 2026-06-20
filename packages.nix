{
  pkgs,
  polarbear,
  llm-agents,
  ...
}:

let
  system = pkgs.system;
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
      rclone
      mcp-nixos
      claude-code
      ollama
      opencode
      gemini-cli
      nb
      llm-agents.packages.${system}.pi
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
