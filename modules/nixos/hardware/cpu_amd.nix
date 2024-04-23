{
  config,
  lib,
  ...
}: let
  kver = config.boot.kernelPackages.kernel.version;
in {
  hardware.cpu.amd.updateMicrocode = true;
  # see https://github.com/NixOS/nixos-hardware/blob/c256df331235ce369fdd49c00989fdaa95942934/common/cpu/amd/pstate.nix
  # and NotAShelf's dots
  boot = lib.mkMerge [
    {
      kernelModules = [
        "kvm-amd" # kernel-based virtual machine
        "amd-pstate" # exposes more P-states than acpi_cpufreq, but does not take over governing
        "msr" # x86 CPU MSR access device
      ];
    }
    (lib.mkIf
      (
        (lib.versionAtLeast kver "5.17")
        && (lib.versionOlder kver "6.1")
      )
      {
        kernelParams = ["initcall_blacklist=acpi_cpufreq_init"];
        kernelModules = ["amd-pstate"];
      })
    (lib.mkIf
      (
        (lib.versionAtLeast kver "6.1")
        && (lib.versionOlder kver "6.3")
      )
      {
        kernelParams = ["amd_pstate=passive"];
      })
    (lib.mkIf (lib.versionAtLeast kver "6.3") {
      kernelParams = ["amd_pstate=active"];
    })
  ];
}
