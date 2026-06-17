{
  flake.modules.homeManager.helix =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.helix = {
        enable = true;
        defaultEditor = true;
        package = pkgs.unstable.helix;
        ignores = [
          "!.github/"
          "!.gitignore"
          "!.gitattributes"
        ];
        settings = {
          editor = {
            color-modes = true;
            bufferline = "multiple";
            line-number = "relative";
            rulers = [
              80
              120
            ];
            text-width = 100;
            soft-wrap = {
              enable = true;
              wrap-at-text-width = true;
            };
            statusline.center = [ "file-type" ];
            statusline.right = [
              "diagnostics"
              "selections"
              "register"
              "position"
              "total-line-numbers"
              "file-encoding"
            ];
            cursor-shape.insert = "bar";
            cursorline = true;
            smart-tab = {
              enable = false;
            };
            lsp.snippets = false;
            auto-pairs = {
              "(" = ")";
              "{" = "}";
              "[" = "]";
            };
            trim-trailing-whitespace = true;
          };
          keys = {
            normal = {
              esc = [
                "collapse_selection"
                "keep_primary_selection"
              ];
              space.t = {
                s = [
                  ":toggle soft-wrap.enable"
                ];
                w = [
                  ":set whitespace.render all"
                ];
                W = [
                  ":set whitespace.render none"
                ];
              };
            };
          };
        };
        languages = {
          language-server = {
            pyright = {
              command = "pyright-langserver";
              args = [ "--stdio" ];
              config = { };
            };
            rust-analyzer.config.check = {
              command = "clippy";
              workspace = true;
              features = "all";
            };
          };
          language = [
            {
              name = "python";
              language-servers = [ "pyright" ];
            }
            {
              name = "markdown";
              block-comment-tokens = {
                start = "<!--";
                end = "-->";
              };
              indent = {
                # What to insert when hitting tab
                # Note that this is two spaces, not one
                unit = "  ";
                # How many spaces to use when rendering a tab character
                tab-width = 2;
              };
            }
          ];
        };
      };
    };
}
