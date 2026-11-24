{ pkgs, ... }: {
  config = {
    environment.systemPackages = with pkgs; [
      (texliveFull.withPackages (
        ps_: with ps_; [
          dvisvgm
          luadraw
        ]
      ))
      ghostscript
      mupdf
    ];
  };
}
