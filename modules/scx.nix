# CPU scheduling through sched_ext: a scheduler loaded from userspace as a
# BPF program, running in place of the kernel's stock CFS.
#
# The i7-1360P mixes 4 P-cores and 8 E-cores, and CFS schedules without
# knowing which is which, so an interactive thread regularly lands on an
# E-core queued behind background work. scx_lavd is built for exactly that
# shape of machine: it classifies tasks by latency requirement and keeps
# the latency-sensitive ones on the P-cores. The Iris Xe caps the average
# frame rate in most games; what this buys is the 1% lows and a desktop
# that stays responsive under heavy background load.
#
# `systemctl stop scx_loader` switches back to CFS without a rebuild, which makes
# before/after comparisons one command. scx_bpfland is the usual
# alternative if a workload dislikes scx_lavd.
{
  services.scx-loader = {
    enable = true;
    config.default_sched = "scx_lavd";
  };
}
