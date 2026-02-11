{ config, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # 1Password SSH Agent integration
    extraConfig = ''
      IdentityAgent "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';

    # Default settings for all hosts
    matchBlocks = {
      "*" = {
        # Connection multiplexing
        controlMaster = "auto";
        controlPath = "~/.ssh/control-%r@%h:%p";
        controlPersist = "10m";

        # Security settings
        hashKnownHosts = true;
        forwardAgent = false;

        # Performance settings
        compression = true;
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };

      # Host-specific configurations can be added here
      # "example" = {
      #   hostname = "example.com";
      #   user = "username";
      #   identityFile = "~/.ssh/id_ed25519";
      # };
    };
  };
}
