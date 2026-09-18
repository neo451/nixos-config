{
  programs.starship = {
    enable = true;
    settings = {
      aws.disabled = true;
      gcloud.disabled = true;
      scan_timeout = 100;
      custom.jj = {
        when = "jj-starship detect";
        shell = [ "jj-starship" ];
        format = "$output ";
      };
    };
  };
}
