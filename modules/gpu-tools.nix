{ pkgs, username, ... }:

# Tools to check and monitor the laptop's Iris Xe: which driver each API
# lands on, and what the GPU and the CPU do under load. Imported by the hosts
# that run on the laptop only; the test VM has no Intel GPU to inspect.
{
  home-manager.users.${username}.home.packages = [
    # vulkaninfo and vkcube: the Vulkan device and driver games will get.
    pkgs.vulkan-tools
    # glxinfo and eglinfo: the OpenGL renderer and whether it is accelerated.
    pkgs.mesa-demos
    # vainfo: hardware video decoding through intel-media-driver.
    pkgs.libva-utils
    # intel_gpu_top: per-engine load and frequency. It reads the i915 perf
    # counters, so it is run with sudo rather than granted a capability.
    pkgs.intel-gpu-tools
    # GPU load per process, read from the i915 fdinfo without privileges.
    pkgs.nvtopPackages.intel
    # sensors: CPU package and core temperatures, to spot thermal throttling.
    pkgs.lm_sensors
  ];
}
