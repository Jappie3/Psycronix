let
  jasper = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA1mAN5Db7eZ0iuBGGxdPqQCR2l6jDZBjgX4ZVOcip27";

  Kainas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACMzy3iXxoPqMidD8ntdW1JQwjBXMQd+Fr0VvC5ftda";
  Torii = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFlv9jSMCR6uILr0hQmud/Ki3qDoyZwuBJS7mn0vN+oU";
  systems = [Kainas Torii];
in {
  "jasper.age".publicKeys = [jasper systems];
  "torii_ap.age".publicKeys = [jasper Torii];
  "loc.age".publicKeys = [jasper];
}
