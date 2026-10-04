{ ... } : {

  imports = [
    ./os
  ];

  config = {

    modules.features.agent.existModule = {
      os = true;
      hm = true;
    };

  };

}
