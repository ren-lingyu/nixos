{
  fetchpatch,
  obs-composite-blur,
  ...
} @ args : (obs-composite-blur.override (

  builtins.removeAttrs args [
    "fetchpatch"
    "obs-composite-blur"
  ]

)).overrideAttrs (oldAttrs_ : {

  patches = builtins.concatLists [
    (oldAttrs_.patches or [])
    [
      (fetchpatch {
        url = "https://github.com/FiniteSingularity/obs-composite-blur/commit/4773875d2ac1335f752b31ca4fb16229bff1a4aa.patch";
        hash = "sha256-V9Mt48a4dALX3t4nXz45tNtKrlEgznjdyPeXYPMpGno=";
      })
    ]
  ];

})
