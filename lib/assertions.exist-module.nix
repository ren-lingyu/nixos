{
  enable,
  value,
  optionPath,
  osModulePath,
  hmModulePath,
  enabledMessage,
} : [

  {
    assertion = value.os == null || value.os == builtins.pathExists osModulePath;
    message = "`${optionPath}.os` must match whether `${builtins.toString osModulePath}` exists.";
  }

  {
    assertion = value.hm == null || value.hm == builtins.pathExists hmModulePath;
    message = "`${optionPath}.hm` must match whether `${builtins.toString hmModulePath}` exists.";
  }

  {
    assertion = (value.os == null) == (value.hm == null);
    message = "`${optionPath}.os` and `${optionPath}.hm` must either both be declared or both be `null`.";
  }

  {
    assertion = !enable || (value.os != null && value.hm != null);
    message = enabledMessage;
  }

]
