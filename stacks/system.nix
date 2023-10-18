{
  config,
  pkgs,
  inputs,
  ...
}:

{
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
    sourceFlake.source = builtins.path {
      name = "sourceFlake";
      path = inputs.self;
      # filter `result`
    };
  };
}
