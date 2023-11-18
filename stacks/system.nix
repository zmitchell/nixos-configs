{
  pkgs,
  inputs,
  ...
}:

{
  system.stateVersion = "23.05";
  nixpkgs.config.allowUnfree = true;

  # Configure the bootloader
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 100;


  # Packages that should be available to all users (including the root user)
  environment.systemPackages = with pkgs; [
    gitFull
    neovim
    just
    ripgrep
    bat
    fd
    zoxide
    atuin
    fzf
    tealdeer
    starship
    jq
  ];

  # Enable the OpenSSH server
  services.openssh.enable = true;

  # Configure Zsh and its plugins for use as the default shell
  programs.zsh.enable = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.autosuggestions.enable = true;
  programs.starship.enable = true;
  programs.starship.settings = {
    format = "\
    $username\
    $hostname\
    $directory\
    $git_branch\
    $git_state\
    $git_status\
    $python\
    $cmd_duration\
    $line_break\
    $nix_shell\
    $character
    ";
    command_timeout = 3000;
    nix_shell.heuristic = true;
    directory.truncate_to_repo = false;
  };
  
  # Enable flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Miscellaneous files we want to appear on the system
  environment.etc = {
    # Store the flake that built the system
    sourceFlake.source = builtins.path {
      name = "sourceFlake";
      # filter out `result`
      path = inputs.self;
    };
  };
}
