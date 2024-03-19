{writeShellScriptBin, ...}:
{
  usage-if-no-args = writeShellScriptBin "usage-if-no-args" ''
    n_args="$1"
    usage="$2"
    if [ "$n_args" -eq 0 ]; then
      echo "$usage"
      exit 1
    fi
  '';
}
