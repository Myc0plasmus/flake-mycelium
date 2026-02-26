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
  inherit (import ./utils { inherit lib; inherit inputs;}) baseColonyModule ;
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
      lib.mapAttrs
        (hostname: colony:
          inputs.nixpkgs.lib.nixosSystem {
            system = colony.system;
            modules = colony.modules;
            specialArgs =
              colony.specialArgs
              // { protoHost = colony.protoHost; };
          })
        config.mycelium.nixosColonies;
  };

}
