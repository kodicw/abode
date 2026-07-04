{ username, homeDirectory, stateVersion ? "25.11" }:

{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = stateVersion;
}