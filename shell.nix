let
  pkgs = import <nixpkgs> {};
  stdenv = pkgs.stdenv;
in stdenv.mkDerivation {
  name = "nvd-clojure-gh-action";
  buildInputs = [
    pkgs.clojure
    pkgs.leiningen
    pkgs.openjdk
  ];
  shellHook = ''
    export GITHUB_TOKEN=$(cat gh_token)
    export GITHUB_REPOSITORY=Swirrl/nvd-clojure-gh-action
    eval $(grep -n2 '\[default\]' ~/.aws/credentials | tail -n2 | cut -d- -f2)
    export AWS_ACCESS_KEY_ID=$aws_access_key_id
    export AWS_SECRET_ACCESS_KEY=$aws_secret_access_key
    export TARGET_PATH=target/nvd
  '';
}
