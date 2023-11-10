{
  config,
  ...
}:
{
  # Enable the WiFi driver for the MediaTek MT7921K chipset
  networking.interfaces.wlan0.useDHCP = true;
  networking.wireless.interfaces = ["wlan0"];
}
