{ config, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings."*" = {
      # The path contains a space ("Group Containers"), and home-manager emits
      # the value verbatim. Without the embedded quotes ssh rejects the whole
      # config file with "extra arguments at end of line".
      IdentityAgent = "\"${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
      ControlMaster = "auto";
      ControlPath = "~/.ssh/control-%r@%h:%p";
      ControlPersist = "10m";
      HashKnownHosts = true;
      ForwardAgent = false;
      Compression = true;
      ServerAliveInterval = 60;
      ServerAliveCountMax = 3;
    };
  };
}
