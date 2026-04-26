# =========================================================================
#      Orange Pi 5 Max Specific Configuration
# =========================================================================
#
# Based on the Orange Pi 5 Plus board module. Key differences:
#   - Device tree: rk3588-orangepi-5-max (compact form factor)
#   - WiFi: AP6611S (BCM43711) via SDIO, not PCIe (AP6275P3)
#   - Ethernet: 1x RTL8125B 2.5GbE (vs 2x on 5 Plus)
#   - Memory: LPDDR5 (vs LPDDR4x)
#   - No HDMI RX, no IR receiver
#
# The vendor kernel (6.1.x from armbian/linux-rockchip) includes:
#   - rk3588-orangepi-5-max.dtb device tree
#   - bcmdhd SDIO driver for AP6611S WiFi (built-in, not a module)
#   - RKNPU driver for Rockchip NPU
#   - RKMPP driver for hardware video codec
#
# WiFi firmware (nvram_ap6611s.txt, BCM43711 blobs) is provided by
# the orangepi-firmware package from orangepi-xunlong/firmware.
# =========================================================================
{
  pkgs,
  rk3588,
  ...
}: let
  pkgsKernel = rk3588.pkgsKernel;
in {
  imports = [
    ./base.nix
    ./dtb-install.nix
  ];

  boot = {
    kernelPackages = pkgsKernel.linuxPackagesFor (pkgsKernel.callPackage ../../pkgs/kernel/vendor.nix {});

    # kernelParams copy from Armbian's /boot/armbianEnv.txt & /boot/boot.cmd
    kernelParams = [
      "rootwait"

      "earlycon" # enable early console, so we can see the boot messages via serial port / HDMI
      "consoleblank=0" # disable console blanking(screen saver)
      "console=ttyS2,1500000" # serial port
      "console=tty1" # HDMI

      # docker/podman optimizations
      "cgroup_enable=cpuset"
      "cgroup_memory=1"
      "cgroup_enable=memory"
      "swapaccount=1"
    ];
  };

  hardware = {
    deviceTree = {
      name = "rockchip/rk3588-orangepi-5-max.dtb";
      overlays = [
      ];
    };

    firmware = [
      (pkgs.callPackage ../../pkgs/orangepi-firmware {})
    ];
  };
}
