{ config, lib, inputs, ... }:

{
  imports = [ inputs.agent-skills-nix.homeManagerModules.default ];

  programs.agent-skills = {
    enable = true;
    sources = {
      builtin-sources = {
        path = ../../modules/skills;
      };
      core-sources = {
        path = ../../agent-skills;
      };
      vercel = {
        input = "vercel-skills";
        subdir = "skills";
      };
      addyosmani = {
        input = "addyosmani-skills";
        subdir = "skills";
      };
      ailabs = {
        input = "ailabs-skills";
        subdir = "packages/skills";
      };
      bigboss = {
        input = "bigboss-skills";
        subdir = ".claude/skills";
      };
      affaan = {
        input = "affaan-skills";
        subdir = ".agents/skills";
      };
      mindrally = {
        input = "mindrally-skills";
        subdir = ".";
        idPrefix = "mindrally";
      };
      unclecatvn = {
        input = "unclecatvn-skills";
        subdir = "skills";
      };
      google-cloud = {
        input = "google-skills";
        subdir = "skills/cloud";
      };
      google-ads = {
        input = "google-skills";
        subdir = "skills/ads";
      };
      google-analytics = {
        input = "google-skills";
        subdir = "skills/analytics";
      };
      xixu = {
        input = "xixu-skills";
        subdir = "skills";
      };
    };
    skills = {
      enableAll = [ "builtin-sources" "core-sources" "google-cloud" "google-ads" "google-analytics" ];
      enable = [
        "find-skills"
        "git-workflow-and-versioning"
        "docker-containerization"
        "nix-best-practices"
        "security-review"
        "odoo-19.0"
        "mindrally/odoo-development"
        "mindrally/postgresql-best-practices"
        "mindrally/docker"
        "mindrally/terraform"
        "github-actions-docs"
      ];
    };
    targets = {
      pi = {
        enable = true;
        structure = "symlink-tree";
      };
      antigravity = {
        enable = true;
        structure = "symlink-tree";
      };
      gemini = {
        enable = true;
        structure = "symlink-tree";
      };
      codex = {
        enable = true;
        structure = "symlink-tree";
      };
      agents = {
        enable = true;
        structure = "symlink-tree";
      };
    };
  };
}
