{
  pkgs,
  inputs,
  ...
}:

{
  system.stateVersion = "23.05";

  environment.systemPackages = with pkgs; [
    gitFull
    neovim
    hello
  ];

  services.openssh.enable = true;
  programs.zsh.enable = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  environment.etc = {
    # Store the flake that built the system
    sourceFlake.source = builtins.path {
      name = "sourceFlake";
      # filter out `result`
      path = inputs.self;
    };
  };
}
