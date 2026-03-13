{
  lib,
  ...
}:
let
  inherit (lib)
  throwIf
  types
  warnIf
  ;

  errorExample = ''
    For example:

        outputs = inputs@{ flake-parts, ... }:
          flake-parts.lib.mkFlake { inherit inputs; } { /* module */ };

    To avoid an infinite recursion, *DO NOT* pass `self.inputs` and
    *DO NOT* pass `inherit (self) inputs`, but pass the output function
    arguments as `inputs` like above.
  '';

  flake-mycelium-lib = rec {
    removeNixSuffix = name:
      lib.removeSuffix ".nix" name;

  growMycelium =
    { modulesPath, blacklist, underBlacklist ? false }:

    let
      entries = builtins.readDir modulesPath;

      results =
        lib.mapAttrsToList
          (name: type:
            let
              fullPath = modulesPath + "/${name}";
            in
            if type == "directory" then
              let
                r = growMycelium {
                  modulesPath = fullPath;
                  inherit blacklist;
                  underBlacklist = underBlacklist || lib.elem name blacklist;
                };
              in
              {
                spores= r.moduleSpores;
                colonies = r.colonyModules;
              }
              
            else if type == "regular" && lib.hasSuffix ".nix" name then
              if underBlacklist then
                {
                  spores = {};
                  colonies = [ fullPath ];
                }
              else
                let 
                  file = import fullPath;
                in
                {
                  spores = file.moduleSpores or {};
                  colonies = [];
                }

            else
              {
                spores = {};
                colonies = [];
              }
          )
          entries;

    in {
      moduleSpores =
        lib.foldl' lib.recursiveUpdate {}
          (map (r: r.spores) results);

      colonyModules =
        lib.concatLists (map (r: r.colonies) results);
    };
    
    evalFlakeModule = 
      args@
      { inputs ? self.inputs
      , specialArgs ? { }

        # legacy
      , self ? inputs.self or (throw ''
          When invoking flake-mycelium, you must pass all the flake output arguments,
          and not just `self.inputs`.

          ${errorExample}
        '')
      , moduleLocation ? "${self.outPath}/flake.nix",
        moduleSpores,
      }:
      let
        inputsPos = builtins.unsafeGetAttrPos "inputs" args;
        errorLocation =
          # Best case: user makes it explicit
          args.moduleLocation or (
            # Slightly worse: Nix does not technically commit to unsafeGetAttrPos semantics
            if inputsPos != null
            then inputsPos.file
            # Slightly worse: self may not be valid when an error occurs
            else if args?inputs.self.outPath
            then args.inputs.self.outPath + "/flake.nix"
            # Fallback
            else "<mkMycelium argument>"
          );
      in
      throwIf
        (!args?self && !args?inputs) ''
        When invoking flake-parts, you must pass in the flake output arguments.

        ${errorExample}
      ''
        warnIf
        (!args?inputs) ''
        When invoking flake-parts, it is recommended to pass all the flake output
        arguments in the `inputs` parameter. If you only pass `self`, it's not
        possible to use the `inputs` module argument in the module `imports`.

        Please pass the output function arguments. ${errorExample}
      ''
      (module:
      lib.evalModules {
        specialArgs = {
          inherit self flake-mycelium-lib moduleLocation moduleSpores;
          inputs = args.inputs or /* legacy, warned above */ self.inputs;
        } // specialArgs;
        modules = [ ./modules (lib.setDefaultModuleLocation errorLocation module) ];
        class = "mycelium";
      }
      );

      mkMycelium = args: module: colonyDirs:
        let
          grownMycelium = growMycelium {
            modulesPath = module;
            blacklist = colonyDirs;
          };
          eval = evalFlakeModule (args // {moduleSpores = grownMycelium.moduleSpores;}) { imports=grownMycelium.colonyModules; };
        in
        eval.config.mycelium;
  };
in
flake-mycelium-lib
