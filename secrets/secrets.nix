let
  jasper = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA1mAN5Db7eZ0iuBGGxdPqQCR2l6jDZBjgX4ZVOcip27";

  Kainas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACMzy3iXxoPqMidD8ntdW1JQwjBXMQd+Fr0VvC5ftda";
  systems = [Kainas];
in {
  # create new secret:
  #agenix -e some-secret.age

  # add secret to a NixOS module config:
  #age.secrets.some-secret.file = ../secrets/some-necret.age;

  # reference the mount path of the secret somewhere:
  #config.age.secrets.some-secret.path

  # define who can decrypt it:
  #"some-secret.age".publicKeys = [jasper];
}
