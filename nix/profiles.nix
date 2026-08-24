let
  mkProfile =
    {
      name,
      developmentFeatures ? true,
      extendedTools ? false,
      extraThemes ? false,
      aliases ? [ "v" ],
      binName ? null,
    }:
    {
      _module.args.profile = {
        inherit
          name
          developmentFeatures
          extendedTools
          extraThemes
          ;
      };
      settings = {
        inherit aliases;
        dont_link = true;
      };
    }
    // (if binName == null then { } else { inherit binName; });
in
{
  full = mkProfile {
    name = "full";
    extendedTools = true;
    extraThemes = true;
  };

  default = mkProfile {
    name = "default";
  };

  minimal = mkProfile {
    name = "minimal";
    developmentFeatures = false;
    binName = "nvim-minimal";
    aliases = [
      "vi"
      "vim"
    ];
  };
}
