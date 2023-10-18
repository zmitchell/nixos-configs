{
  config,
  options,
  inputs,
  pkgs,
  ...
}:

{
  users.users.zmitchell = {
    name = "zmitchell";
    isNormalUser = true;
    initialPassword = "let-me-in";
    shell = pkgs.zsh;

    packages = with pkgs; [
      # put stuff here
    ];
  };
}
