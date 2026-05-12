# hermes.nix
{pkgs, ...}: {
  services.hermes-agent = {
    enable = true;

    # ── Declarative config (renders to cli-config.yaml) ──
    config = {
      model = {
        default = "anthropic/claude-opus-4.6";
        provider = "openrouter";
      };
      terminal = {
        backend = "local";
        timeout = 180;
        lifetime_seconds = 300;
      };
      agent = {
        max_turns = 60;
        reasoning_effort = "medium";
      };
      memory = {
        memory_enabled = true;
        user_profile_enabled = true;
        memory_char_limit = 2200;
        nudge_interval = 10;
      };
      compression = {
        enabled = true;
        threshold = 0.85;
        summary_model = "google/gemini-3-flash-preview";
      };
      toolsets = ["all"];
    };

    # ── Secrets (not in Nix store) ──
    environmentFiles = [
      "/run/secrets/hermes-env" # ANTHROPIC_API_KEY, TELEGRAM_TOKEN, etc.
    ];

    # ── Non-secret env vars ──
    environment = {
      LLM_MODEL = "anthropic/claude-opus-4.6";
    };

    # ── Workspace documents (inline or file paths) ──
    documents = {
      "SOUL.md" = ''
        # SOUL.md
        You are a sharp, pragmatic AI assistant.
      '';
      "AGENTS.md" = ''
        # AGENTS.md
        Read SOUL.md first. Then help the user.
      '';
      "USER.md" = ''
        # USER.md
        Name: Your Human
      '';
      # Or reference a file:
      # "SOUL.md" = ./documents/SOUL.md;
    };

    # ── Declarative skills (phase 1) ──
    skills = {
      bundled.enable = true;
      optional = [
        "creative/blender-mcp"
      ];
      # custom = {
      #   repo-watch = {
      #     category = "research";
      #     source = ./skills/repo-watch;
      #   };
      # };
    };

    # ── MCP servers ──
    mcpServers = {
      context7 = {
        command = "npx";
        args = ["-y" "@upstash/context7-mcp@latest"];
      };
    };

    # ── Extra tools on PATH ──
    extraPackages = with pkgs; [jq ripgrep curl];
  };
}
