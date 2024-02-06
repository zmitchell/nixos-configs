{
  pkgs,
  ...
}:

{
  system.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;

  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = "nix-command flakes";

  security.sudo.wheelNeedsPassword = false;

  # Enable the OpenSSH server
  services.openssh.enable = true;

  # Git config
  programs.git.enable = true;



  # Packages that should be available to all users (including the root user)
  environment.systemPackages = with pkgs; [
    neovim
    helix
    ripgrep
    jq
  ];
}
