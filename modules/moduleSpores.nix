{ 
lib,
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
    mycelium.moduleSpores = mkOption {
      type = with types; attrsOf anything;
      default = { };
    };
  };
}
