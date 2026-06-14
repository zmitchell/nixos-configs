{config, lib, pkgs, user, ...}:
let
  cfg = config.git;
in
{
  options.git = {
    enable = lib.mkEnableOption "Enable end-user git configuration on this machine.";
    gh.enable = lib.mkEnableOption "Enable a configured 'gh' CLI.";
    jj.enable = lib.mkEnableOption "Enable jujutsu.";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = {
        user.name = user.fullName;
        user.email = user.email;
        init.defaultBranch = "main";
        merge.conflictStyle = "diff3";
        rebase.autoStash = true;
        rerere.enabled = true;
        push.autoSetupRemote = true;
        commit.cleanup = "strip";
        pull.ff = "only";
      };
      ignores = import ./../data/git-ignores.nix;
    };

    programs.difftastic = {
      enable = true;
      git.enable = true;
    };

    programs.gh = lib.mkIf cfg.gh.enable {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = "hx";
        prompt = "enabled";
        extensions = with pkgs; [
          gh-dash
        ];
      };
    };

    programs.jujutsu = lib.mkIf cfg.jj.enable {
      enable = true;
      package = pkgs.unstable.jujutsu;
      settings = {
        user = {
          email = user.email;
          name = user.fullName;
        };
        ui = {
          paginate = "never";
          default-command = [ "status" ];
          diff-editor = ":builtin";
        };
        git = {
          write-change-id-header = true;
        };
        revset-aliases = {
          branch = "main::@";
          "closest_pushable(to)" =
            "heads(::to & mutable() & ~description(exact:\"\") & (~empty() | merges()))";
        };
        aliases = {
          l = [
            "log"
            "-r"
            "(trunk()..@):: | (trunk()..@)-"
            "--reversed"
          ];
          lpr = [
            "log"
            "-r"
            "(trunk()..@):: | (trunk()..@)"
            "-T"
            "description ++ \"\n\""
            "--no-graph"
            "--reversed"
          ];
          tug = [
            "bookmark"
            "move"
            "--from"
            "heads(::@ & bookmarks())"
            "--to"
            "closest_pushable(@)"
          ];
          init = [
            "git"
            "init"
            "--colocate"
            "."
          ];
        };
        templates = {
          log_node = "label(\"node\",coalesce(if(!self, label(\"elided\", \"~\")),if(current_working_copy, label(\"working_copy\", \"@\")),if(conflict, label(\"conflict\", \"×\")),if(immutable, label(\"immutable\", \"*\")),label(\"normal\", \"·\")))";
          draft_commit_description = ''
            concat(
              "JJ: Short description limit (50 characters)",
              "\nJJ: ----------------------------------------------\n",
              coalesce(description, default_commit_description, "\n"),
              "JJ: Body limit (72 characters)",
              "\nJJ: --------------------------------------------------------------------",
              "\nJJ: <type>[scope]: <description>",
              "\nJJ: Types:",
              "\nJJ: - feat",
              "\nJJ: - fix",
              "\nJJ: - chore",
              "\nJJ: - perf",
              "\nJJ: - docs",
              "\nJJ: - style",
              "\nJJ: - refactor",
              "\nJJ: - test",
              "\n",
              "JJ: Change ID: " ++ format_short_change_id(change_id),
              "\n",
              surround(
                "JJ: This commit contains the following changes:\n", "",
                indent("JJ:     ", diff.summary()),
              ),
              "JJ: ignore-rest\n",
              diff.git()
            )
          '';
        };
      };
    };
  };
}
