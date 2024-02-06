{
  pkgs,
  ...
}:

{
  system.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;
  # Enable flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  security.sudo.wheelNeedsPassword = false;

  # Enable the OpenSSH server
  services.openssh.enable = true;

  # Packages that should be available to all users (including the root user)
  environment.systemPackages = with pkgs; [
    gitFull
    neovim
    helix
    ripgrep
    jq
  ];
}
