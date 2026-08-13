{
  lib,
  ...
}:
let
  user.options = {
    fullName = lib.mkOption {
      type = lib.types.str;
      description = "The user's first and last name. Used in git config, etc.";
      example = "John Doe";
    };
    username = lib.mkOption {
      type = lib.types.str;
      description = "The user's username as they'll use to log in.";
      example = "johndoe";
    };
    email = lib.mkOption {
      type = lib.types.str;
      description = "The user's email. Used in git config.";
      example = "jdoe@example.com";
    };
  };
  common = {
    options.user_profile = lib.mkOption {
      type = lib.types.submodule user;
      description = "The user's system-relevant identifying information.";
    };
  };
in
{
  flake.modules.generic.user_profile_home = {
    imports = [ common ];
    config.user_profile = {
      fullName = "Zach Mitchell";
      username = "zmitchell";
      email = "zmitchell@fastmail.com";
    };
  };
  flake.modules.generic.user_profile_work = {
    imports = [ common ];
    config.user_profile = {
      fullName = "Zach Mitchell";
      username = "zmitchell";
      email = "zmitchell@halcyon.ai";
    };
  };
}
