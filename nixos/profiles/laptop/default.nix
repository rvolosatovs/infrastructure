{ config, pkgs, ... }:
let
  unstable = import <nixpkgs-unstable> {};
in
  {
    imports = [
      ./../..
      ./../../../vendor/nixos-hardware/common/pc/laptop
      ./../../boards.nix
      ./../../graphical.nix
      ./../../mopidy.nix
      ./../../virtualbox.nix
    ];

    home-manager.users.${config.meta.username} = {...}: {
      imports = [
        ../../../home/profiles/laptop
        ../../../vendor/secrets/home
      ];

      programs.go.package = unstable.go;
    };

    nixpkgs.overlays = [
      (self: super: {
        inherit (unstable)
        gotools
        ;
      })
    ];


    programs.adb.enable = true;

    services.printing.enable = true;

    sound.enable = true;
    sound.mediaKeys.enable = true;

    systemd.services.audio-off.description = "Mute audio before suspend";
    systemd.services.audio-off.enable = true;
    systemd.services.audio-off.serviceConfig.ExecStart = "${pkgs.pamixer}/bin/pamixer --mute";
    systemd.services.audio-off.serviceConfig.RemainAfterExit = true;
    systemd.services.audio-off.serviceConfig.Type = "oneshot";
    systemd.services.audio-off.serviceConfig.User = "${config.meta.username}";
    systemd.services.audio-off.wantedBy = [ "sleep.target" ];

    users.users.${config.meta.username}.extraGroups = [
      "adbusers"
    ];
  }
