{
  pkgs,
  aiExtensions,
  claude-plugins-official,
  ponytail,
  go-modern-guidelines,
  caveman,
  cloudflare-skills,
  ...
}:

let
  hook = matcher: command: extra: [
    {
      inherit matcher;
      hooks = [
        (
          {
            type = "command";
            inherit command;
          }
          // extra
        )
      ];
    }
  ];
  claudeSettings = {
    agentPushNotifEnabled = true;
    autoUpdatesChannel = "latest";
    effortLevel = "medium";
    includeCoAuthoredBy = true;
    model = "sonnet";
    env = {
      CLAUDE_CODE_NO_FLICKER = "1";
    };
    permissions = {
      allow = [
        "Bash(darwin-rebuild build *)"
        "Bash(fd *)"
        "Bash(gh api *)"
        "Bash(gh pr list *)"
        "Bash(gh pr view *)"
        "Bash(gh repo *)"
        "Bash(git add *)"
        "Bash(git branch *)"
        "Bash(git commit *)"
        "Bash(git diff *)"
        "Bash(git log *)"
        "Bash(git show *)"
        "Bash(git status)"
        "Bash(home-manager build *)"
        "Bash(jq *)"
        "Bash(ls *)"
        "Bash(mkdir *)"
        "Bash(rg *)"
        "Bash(tar *)"
        "Bash(which *)"
      ];
      deny = [
        "Bash(curl *)"
        "Read(.env)"
        "Read(credentials.json)"
        "Bash(find *)"
        "Bash(grep *)"
      ];
      ask = [
        "Bash(rm *)"
        "Bash(git rm *)"
        "Bash(git push *)"
        "Bash(gh pr create *)"
        "Bash(home-manager switch *)"
      ];
      defaultMode = "auto";
    };
    hooks = {
      SessionStart = hook "*" "bash ~/.claude/hooks/herdr-agent-state.sh session" { timeout = 10; };
    };
    sandbox = {
      enabled = false;
      autoAllowBashIfSandboxed = true;
      enableWeakerNetworkIsolation = true;
    };
    autoMode.environment = [
      "### Org-wide"
      "**Organization**: None configured"
      "**Cloud provider(s)**: None configured"
      "**Repository visibility**: public — github.com/earlgray283/dotfiles"
      "**Internal sharing / snippet hosting**: None configured — treat public paste/gist services as outside the trust boundary"
      "**Secrets management**: CI secret names referenced only (DOTFILES_GITHUB_TOKEN, GITHUB_TOKEN) — values not stored or accessible; no secrets manager configured"
      "**Default / protected branches**: main (default); no branch protection configured"
      "**CI/CD deploy targets**: None configured"
      "**Network posture**: None configured"
      "**Host containment**: None configured — assume Claude Code runs on an ordinary developer machine (macOS) with open internet"
      "**Source control**: The trusted repo (github.com/earlgray283/dotfiles) and its remote only — no additional orgs configured"
      "**Trusted internal domains**: None configured"
      "**Trusted cloud buckets**: None configured"
      "**Key internal services**: None configured"
      "**Internal package registry**: None configured"
      "**Sensitive data locations & audiences**: any file or store holding personal data, confidential business data, credentials, regulated data, or similarly sensitive material; preserve exact handles when known and share only with audiences cleared at the [named+specifics] bar"
      "**Data retention / declassification**: None configured"
      "**Sensitive remote targets**: any namespace, host, or container whose name carries `prod` or `production` as a whole word or name segment"
      "**Protected deployment namespaces / environments**: None configured — fall back to the Sensitive remote targets heuristic"
      "**Protected IaC scopes**: IAM, RBAC, networking, quota, and node-pool resources; anything whose name or tag carries `prod` or `production` as a whole word or name segment"
      "### User-specific"
      "**Primary use of Claude Code**: software development (personal dotfiles management — nix-darwin, Home Manager, mise configuration)"
      "**Trusted repo**: ~/dev/dotfiles (github.com/earlgray283/dotfiles) — PUBLIC repo; only this repo's own work belongs here, content ported from elsewhere is not"
      "**Org-specific CLIs**: mise, nix, fd, hm, home-manager, nixfmt (project-standard tooling observed in repo usage; no org-wide CLI registry configured)"
      "**Routine under earlgray283/dotfiles prefix**: routine git/mise/nix operations scoped to this repo and its justfile targets (e.g. switch-home-manager, install-mise, update-ai) are expected/trusted"
    ];
  };
in
{
  programs.claude-code = {
    enable = true;

    package = null;

    enableMcpIntegration = true;

    settings = claudeSettings;

    context = ./instructions.md;

    marketplaces = {
      inherit
        claude-plugins-official
        ponytail
        go-modern-guidelines
        caveman
        ;
      cloudflare = cloudflare-skills;
    };

    plugins = aiExtensions.claudePlugins;

    skills = aiExtensions.claudeSkills;
  };

  home.file.".claude/hooks/herdr-agent-state.sh".source =
    (import ../../lib/herdr-integrations.nix { inherit pkgs; }).claudeHook;
}
