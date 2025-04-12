# NixOS Configs

These are my configs for my NixOS/nix-darwin machines.

### Installation

I've installed using various methods:
- Graphical installer
- `disko-install`
- Manual installation
- Hybrid of manual installation with `disko` configured partitions

Lately my process looks like this:
- I have a flake that configures all of my systems together.
- There are some disk configs in `./setup`.
- When installing on a new machine that I have physical access to, boot into the graphical installer.
- Copy and hardcode in the values from one of the disk configs (this amounts to setting the `device` and `username`). Also edit it so that you can just import it rather than calling it as a function that produces a module.
- Run the `disko` partitioning command (look in their docs).
- Create the `configuration.nix` and `hardware-configuration.nix` according to their instructions, making sure to import the `disko` module and the disk config in this machine's config.
- If you remember, edit `configuration.nix` to add a user and set an initial password, otherwise you'll find yourself needing to use `root` to log in.
- Run `nixos-install` and find out where you screwed up the config.
- Once it's done, boot. You probably don't have Wi-Fi at this point, so connect to ethernet.
- Get a `git` package via `nix-shell -p git` so that you can clone the flake.
- Clone the flake, copy over modifications like the disk config, then try to `nixos-rebuild switch` into it.
- Cross your fingers and hope that it works.

## License

Licensed under either of

 * Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally
submitted for inclusion in the work by you, as defined in the Apache-2.0
license, shall be dual licensed as above, without any additional terms or
conditions.
