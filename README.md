# pidrive-install
"1-Click" installer for hcxdumptool wardriving on a Raspberry Pi and similar SBCs.

## Requirements

- Needs to run on Raspberry Pi OS
- The default user needs to be named "pi" (this will be fixed in the future)
- It's recommended to run this on a fast SD card, otherwise installation will take ages. Wardriving itself doesn't require fast storage.

## Installation

### Prepare Raspberry Pi OS

- Download the latest Raspberry Pi OS Lite from https://www.raspberrypi.org/software/operating-systems/
- After flashing it on an SD card, go to the boot partition and create an empty file called `ssh` (this will enable ssh on the first boot so you can access the Pi headlessly)

### Run the installer

- (Recommended) Change the Pis hostname to something else than raspberry, you can do so by running ``# raspi-config``
- (Recommended) Change the default pi password (raspberry), you can do so by running ``$ passwd``
- On the Pi, install git: ``# apt install git``
- Clone this repository: ``$ git clone https://github.com/Czechball/pidrive-install.git``
- Go into its directory and start the first installation script: ``$ cd pidrive-install``, ``# ./install.sh`` (this will take a long time on slow SD cards, over an hour)
- Complete any prompts (mainly the one shown when installing macchanger, select "No") and reboot the Pi when finished
- After the reboot, go to the pidrive-install directory again and start the second installation script: ``# ./finalize.sh``

## Getting interfaces ready

- To create a service and exclude a wireless interface from dhcpcd, simply run ``# add-interface.sh``
- When interface is added, you should reconnect it to properly initialize systemd services

### Supported interfaces

Generally, all interfaces with in-kernel drivers which support monitor mode and packet injection should work just fine. In addition, this project supports some chipsets which require special drivers:
- RTL8812au (dual band, in some Alfa cards) - provided by [rtl8812au](https://github.com/aircrack-ng/rtl8812au)
- RTL88x2bu (dual band, in cheaper and generic interfaces) - provided by [rtl88x2bu](https://github.com/cilynx/rtl88x2bu)
- RT8188e(us), RT8192e, RT8192c, RT8723a and RT8723b (in some TP-Link interfaces) - provided by [realtek_rtwifi](https://github.com/kimocoder/realtek_rtwifi)

Additionally, there's a bug in Debian where some firmware files (MT7610U and similar MediaTeks) are misplaced by the firmware-misc-nonfree package. We fix this issue in `install.sh` by simply downgrading the package.

### Tested interfaces

These interfaces were tested with this setup and were confirmed to work without any significant issues:

- TP-Link Archer T2UH (MT7610U) [dual band] - requires downgrading the firmware-misc-nonfree package, has full NETLINK support | **Recommended for 2.4 GHz only, 5 GHz reception is bad**
- ASUS USB-AC51 (MT7610U) [dual band] - requires downgrading the firmware-misc-nonfree package, has full NETLINK support | **Performs very well relatively to its size, almost comparable to Archer T2UH. 5 GHz reception is sadly also not good.**
- Alfa AWUS036ACH (RTL8812au) [dual band] - requires [rtl8812au](https://github.com/aircrack-ng/rtl8812au), doesn't support NETLINK (hcxdumptool will complain but it works fine) | **Recommended, has very good reception on both bands**
- Alfa AWUS036NH (RT3070) [single band] - no extra requirements, full NETLINK support. | **Recommended for single band usage, has great reception**
- TP-Link TL-WN722N v2/v3 (RTL8188EUS) [single band] - requires [realtek-rtwifi](https://github.com/kimocoder/realtek_rtwifi) for best performance, has full NETLINK support | **Pretty good performance for its size, similar to Archer T2UH**
- AC1200 Techkey (generic, might have different names or brands) (RTL88x2bu) [dual band] - requires [rtl88x2bu](https://github.com/cilynx/rtl88x2bu), doesn't support NETLINK (hcxdumptool will complain but it works fine). This interace is sometimes branded as just simply "Wifi 1200 USB3.0" with no mentions of brand or model. Be cautious about the chipset when buying these, only RTL88x2bu has been tested so far. | **Mediocre performance on both bands, can be a good addition to an existing system. Capture 5 GHz just fine.**

### Known bad cards

These interfaces were tested and proved problematic, unstable or just straight up don't work

- Alfa AWUS1900 (RTL8814au) [dual band] - this is a card with excellent performance but sadly its driver doesn't support packet injection. Monitor mode works ([https://github.com/aircrack-ng/rtl8814au](rtl8814au) is required) so this interface is still useful for passive monitoring, for example with Kismet or airodump-ng. NETLINK is also not supported.
- TP-Link TL-WN722N v1 (AR9271) [single band] - this interface supports monitor mode and packet injection, but its driver is very unstable and can cause kernel panics and other problems. The interface itself is also prone to overheating. The driver is shipped with kernel.

## Usage

After interfaces are added and services are enabled, hcxdumptool will start on boot. Capture files will be saved in `/opt/wardriving` in folders numbered after their respective session. Sessions are incremented after each system boot, this is managed by the `hcx-sesssion` service. Logs (hcxdumptool output) are saved in `/opt/wardriving/logs`

## Disclaimer

By default, hcxdumptool attacks all nearby networks by exploiting the wpa protocol to retrieve PMKIDs or deauthenticates clients to get their EAPOL hashes. You should only run this system in controlled pentesting environments or limit hcxdumptool's activities to your own networks with its whitelist feature. Don't be evil.
