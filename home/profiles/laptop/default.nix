{ config, pkgs, lib, ... }:

{
  imports = [
    ./../..
    ./../../graphical.nix
    ./../../keybase.nix
    ./../../pass.nix
  ];

  config = {
    home.packages = with pkgs; [
      #platformio
      alsaUtils
      arduino
      asciinema
      clang
      drive
      gocode
      gotools
      httpie
      julia
      keybase
      llvm
      llvmPackages.libclang
      macchanger
      nixops
      playerctl
      poppler_utils
      taskwarrior
      wineStaging
      winetricks
    ] ++ (with gitAndTools; [
      ghq
      git-extras
      git-open
      tig
    ]);

    programs.firefox.enableAdobeFlash = true;
    programs.git.signing.key = config.meta.gpg.publicKey.fingerprint;
    programs.git.signing.signByDefault = true;
    programs.go.enable = true;
    programs.go.goPath = "";
    programs.go.goBin = ".local/bin.go";
    programs.go.packages = with lib;
    let
      fromGitMap = host: namespace: map (name: nameValuePair "${namespace}/${name}" (builtins.fetchGit "${host}/${name}").outPath);
    in
    listToAttrs ( fromGitMap "https://github.com" "github.com" [
      "BurntSushi/toml"
      "BurntSushi/xgb"
      "mohae/deepcopy"
      "pkg/errors"

    ] ++ fromGitMap "https://go.googlesource.com" "golang.org/x" [
      "crypto"
      "exp"
      "text"
      "time"
    ]);

    systemd.user.services.godoc.Unit.Description="Godoc server";
    systemd.user.services.godoc.Service.Environment="'GOPATH=${config.home.sessionVariables.GOPATH}'";
    systemd.user.services.godoc.Service.ExecStart="${pkgs.gotools}/bin/godoc -http=:42002";
    systemd.user.services.godoc.Service.Restart="always";
  };
}
