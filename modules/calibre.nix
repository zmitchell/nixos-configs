{ config, lib, pkgs, ...}:
let
  cfg = config.calibre;
  # Necessary for adding to the list of dependencies
  python = pkgs.python3.override {
    self = python;
    packageOverrides = self: super: {
      sqlalchemy = super.sqlalchemy_1_4;
    };
  };
  patchedCalibreWeb = pkgs.calibre-web.overrideAttrs (oldAttrs: {
    # Add optional dependencies that enable additional metadata providers
    propagatedBuildInputs = (with python.pkgs; [
      rarfile
      markdown2
      html2text
      python-dateutil
      beautifulsoup4
      faust-cchardet
    ]) ++ oldAttrs.propagatedBuildInputs;

    postPatch = ''
      # Increase the maximum upload size
      sed -i 's/209700000/500000000/g' cps/server.py
      # Limit Google metadata search results to English
      sed -i 's/?q=/?lr=lang_en\&q=/' cps/metadata_provider/google.py
    '' + oldAttrs.postPatch;
  });
in
{
  options.calibre = {
    enable = lib.mkEnableOption "Enable the calibre-server and calibre-web services.";
    calibreServerPort = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = lib.mdDoc "Port for the calibre-server server.";
    };
    calibreWebPort = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = lib.mdDoc "Port for the calibre-web server.";
    };
    useReverseProxy = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to put these services behind the reverse proxy.";
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "calibre";
      description = "Which user will run the calibre services";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "calibre";
      description = "Which group the calibre services run under.";
    };
  };

  config = 
  let
    # libraryDir = builtins.elemAt config.services.calibre-server.libraries 0;
    libraryDir = "/var/lib/calibre";
  in
  lib.mkIf cfg.enable {
    services.calibre-web = {
      enable = true;
      package = patchedCalibreWeb;
      user = builtins.toString cfg.user;
      group = cfg.group;
      openFirewall = lib.mkIf cfg.useReverseProxy true;
      listen = {
        port = cfg.calibreWebPort;
        ip = "127.0.0.1";
      };
      options = {
        enableBookUploading = true;
        calibreLibrary = libraryDir;
      };
    };

    users.users = {
      ${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
      };
    };

    users.groups = {
      ${cfg.group} = {};
    };

    systemd.tmpfiles.rules = [
      "d ${libraryDir} 0775 ${cfg.user} ${cfg.group} -"  
    ];

    systemd.services.calibre-init = {
      description = "Initializes the calibre library and database.";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Group = cfg.group;
        RemainAfterExit = "yes";
        Restart = "no";
        ExecStart = [
          "${pkgs.coreutils}/bin/touch ${libraryDir}/foo.txt"
          "${pkgs.calibre}/bin/calibredb add ${libraryDir}/foo.txt --with-library ${libraryDir}"
          "${pkgs.coreutils}/bin/rm ${libraryDir}/foo.txt"
          # 1 is the id of the book we just added
          "${pkgs.calibre}/bin/calibredb remove 1 --with-library ${libraryDir}"
        ];
      };
    };
    systemd.services.calibre-web.after = [ "calibre-server.service" ];

    reverse_proxy.services.books = lib.mkIf cfg.useReverseProxy {
      subdomain = "books";
      port = cfg.calibreWebPort;
    };
  };
}
