{ config, acmeEmail, ... }:
{
  services.rag-server = {
    enable = true;
    port = 8090;
    host = "127.0.0.1";

    # Domain for nginx + SSL
    domain = "rag.msdqn.dev";
    acmeEmail = acmeEmail;

    # OpenAI settings (or OpenRouter)
    openaiApiBase = "https://api.openai.com/v1";
    openaiModel = "gpt-4o-mini";
    embeddingModel = "text-embedding-3-small";

    # Secret file with OPENAI_API_KEY
    environmentFile = config.sops.secrets.rag_server_env.path;
  };

  # Ensure rag-server starts after sops secrets are available
  systemd.services.rag-server = {
    after = [ "sops-nix.service" ];
    wants = [ "sops-nix.service" ];
  };
}
