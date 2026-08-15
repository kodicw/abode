## 1. Program Configuration & Integration

- [x] 1.1 Research Home Manager module for `pi-coding-agent` (provided via `inputs.agent-skills-nix.homeManagerModules.default`).
- [x] 1.2 Enable and configure `programs.pi-coding-agent` in `modules/programs/ai.nix` with package `llm-agents.packages.${system}.pi` and settings (`opencode-go`, `deepseek-v4-flash`, `high`, `git:github.com/kodicw/pi-voice`).

## 2. Verification

- [x] 2.1 Verify Nix flake check and dry-run evaluation across homeConfigurations.
