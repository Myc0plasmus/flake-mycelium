{
  inputs,
  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkOption
    types
    ;
  inherit (import ./utils { inherit lib;}) baseColonyModule ;
in
{
  options = {
    mycelium.nixosColonies =
      let
        hostType = types.submodule [
          baseColonyModule
        ];
      in
      mkOption {
        type = types.attrsOf hostType;
        default = { };
      };
  };

  config = {
    mycelium.nixosConfigurations =
      let
        mkHost =
          hostname: options:

          inputs.nixpkgs.lib.nixosSystem {
            inherit (options)
              system
              modules
              specialArgs
              ;
          };
      in
      lib.mapAttrs mkHost config.mycelium.nixosColonies;
  };

}
