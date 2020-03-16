# finalfusion Nix package set

This is a [Nix](https://nixos.org/nix/) package set for finalfusion.

## Supported nixpkgs releases

We pin [nixpkgs](https://github.com/NixOS/nixpkgs) to ensure that the
packages build on every Nix/NixOS configuration.

## Using the repository

### One-off installs

One-off package installs can be performed without configuration
changes, using e.g. `nix-env`:

~~~shell
$ nix-env \
  -f https://github.com/finalfusion/nix-packages/archive/master.tar.gz \
  -iA finalfrontier
~~~

### Adding the repository

If you want to use multiple packages from the repository or get
package updates, it is recommended to add the package set to your
local Nix configuration. You can do this be adding the package set to
your `packageOverrides`. To do so, add the following to
`~/.config/nixpkgs/config.nix`:

~~~nix
{
  packageOverrides = pkgs: {
    finalfusion = import (builtins.fetchTarball "https://github.com/finalfusion/nix-packages/archive/master.tar.gz") {};
  };
}
~~~

Then the packages will be available as attributes under `finalfusion`,
e.g. `finalfusion.finalfrontier`.

### Pinning a specific revision

Fetching the repository tarball as above will only cache the
repository download for an hour. To avoid this, you should pin the
repository to a specific revision.

~~~nix
{
  packageOverrides = pkgs: {
    finalfusion = import (builtins.fetchTarball {
      # Get the archive for commit a4dea5d
      url = "https://github.com/finalfusion/nix-packages/archive/a4dae5d6c3b62ca9b91c786d9abc1ffe12aa6aff.tar.gz";
      # Get the SHA256 hash using: nix-prefetch-url --unpack <url>
      sha256 = "0nhsadvc5i4sw7pk2q42bp9lxqp6w2d1yy4sanydg60ylz6712a5";
    }) {};
  };
}
~~~

## Binary cache

After each commit, CI uploads builds to
[cachix](https://cachix.org/). If you want to use this binary cache,
follow the steps described at
[finalfusion.cachix.org](https://finalfusion.cachix.org/).
