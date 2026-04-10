finalPkgs: prevPkgs: {
  fastfetch = prevPkgs.fastfetch.overrideAttrs (
    finalAttrs: prevAttrs: {
      patches = [
        /*patch: create_nixowos_logo.patch*/
        ./create_nixowos_logo.patch
      ];
    }
  );
}