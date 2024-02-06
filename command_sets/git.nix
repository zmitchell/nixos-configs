{ symlinkJoin, writeShellScriptBin, writeShellApplication, git, ... }:
let
  usage-if-no-args = writeShellScriptBin "usage-if-no-args" ''
    n_args="$1"
    usage="$2"
    if [ "$n_args" -eq 0 ]; then
      echo "$usage"
      exit 1
    fi
  '';

  gh-clone = writeShellApplication {
    name = "gh-clone";
    runtimeInputs = [ git usage-if-no-args ];

    text = ''
      usage="Usage: gh-clone <owner>/<repo>"
      ${usage-if-no-args}/bin/usage-if-no-args "$#" "$usage"
      repo_name="''${1##*/}"
      ${git} clone "git@github.com:$1.git"
      cd "$repo_name"
    '';
  };

  fetch-rebase = writeShellApplication {
    name = "fetch-rebase";
    runtimeInputs = [ git usage-if-no-args ];

    text = ''
      usage="Usage: fetch-rebase <branch>"
      ${usage-if-no-args}/bin/usage-if-no-args "$#" "$usage"
      ${git} fetch origin "$1"
      ${git} rebase "$1"
    '';
  };

  set-upstream = writeShellApplication {
    name = "set-upstream";
    runtimeInputs = [ git usage-if-no-args ];

    text = ''
      usage="Usage: set-upstream [<remote>] <branch>"
      ${usage-if-no-args}/bin/usage-if-no-args "$#" "$usage"
      case "$#" in
        0)
          ${git} push --set-upstream origin "$(basename "$PWD")"
          ;;
        1)
          ${git} push --set-upstream origin "$1"
          ;;
        2)
          ${git} push --set-upstream "$1" "$2"
          ;;
        *)
          echo "$usage"
          exit 1
          ;;
      esac
    '';
  };

  worktree-clone = writeShellApplication {
    name = "worktree-clone";
    runtimeInputs = [ git usage-if-no-args ];

    text = ''
      usage="Usage (from parent of trees): worktree-clone <project name> <URL>"
      ${usage-if-no-args}/bin/usage-if-no-args "$#" "$usage"
      project_name="$1"
      url="$2"
      mkdir "$project_name"
      cd "$project_name"
      ${git} clone "$url" master
      cd master
    '';
  };

  new-worktree = writeShellApplication {
    name = "new-worktree";
    runtimeInputs = [ git usage-if-no-args ];

    text = ''
      usage="Usage (from master worktree): new-worktree <name> [<file to symlink>, ...]"
      ${usage-if-no-args}/bin/usage-if-no-args "$#" "$usage"
      worktree_name="$1"
      # Create a new branch and worktree with the same name
      ${git} worktree add -b "$worktree_name" "../$worktree_name"
      # Symlink any specified files into the new worktree
      if [ "$#" -gt 1 ]; then
        for f in "''${@:2}"; do
          ln -s "$PWD/$f" "$PWD/../$worktree_name/$f"
          echo "symlinked $f"
        done
      fi
      # cd into the new worktree
      cd "../$worktree_name"
    '';
  };

  remove-worktree = writeShellApplication {
    name = "remove-worktree";
    runtimeInputs = [ git usage-if-no-args ];

    text = ''
      usage="Usage (from master worktree): remove-worktree <name> [<name>, ...]"
      ${usage-if-no-args}/bin/usage-if-no-args "$#" "$usage"
      for n in "$@"; do
        ${git} worktree remove -f "../$n"
        ${git} branch -D "$n"
      done
    '';
  };

  pr-worktree = writeShellApplication {
    name = "pr-worktree";
    runtimeInputs = [ git usage-if-no-args ];

    text = ''
      usage="Usage (from master worktree): pr-worktree <pr #> <name>"
      ${usage-if-no-args}/bin/usage-if-no-args "$#" "$usage"
      pr_number="$1"
      worktree_name="$2"
      ${git} pull
      # Fetch the PR branch to our local '$worktree_name' branch
      ${git} fetch origin "pull/$pr_number/head:$worktree_name"
      ${git} worktree add "../$worktree_name" "$worktree_name"
      cd "../$worktree_name"
    '';
  };

  upstream-pr-worktree = writeShellApplication {
    name = "upstream-pr-worktree";
    runtimeInputs = [ git usage-if-no-args ];

    text = ''
      usage="Usage (from master worktree): upstream-pr-worktree <pr #> <name>"
      ${usage-if-no-args}/bin/usage-if-no-args "$#" "$usage"
      pr_number="$1"
      worktree_name="$2"
      ${git} pull
      # Fetch the PR branch to our local '$worktree_name' branch
      ${git} fetch upstream "pull/$pr_number/head:$worktree_name"
      ${git} worktree add "../$worktree_name" "$worktree_name"
      cd "../$worktree_name"
    '';
  };

in symlinkJoin {
  name = "git-helpers";
  paths = [
    gh-clone
    fetch-rebase
    set-upstream
    worktree-clone
    new-worktree
    remove-worktree
    pr-worktree
    upstream-pr-worktree
  ];
}
