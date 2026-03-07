{ 
lib,
sporeSpecies,
...
}:

let
  inherit (lib)
    mkOption
    types
    ;
in
{
  options = {

    mycelium.moduleSpores = builtins.listToAttrs (
    map (sporeSpeciesName: 
    {
      name = sporeSpeciesName;
      value = mkOption {
        type = with types; attrsOf deferredModule;
        default = {};
      };
    }) sporeSpecies );

  };
}
