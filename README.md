# pidrive-install
"1-Click" installer for hcxdumptool wardriving on a Raspberry Pi and similar SBCs.

## Installation

### Prepare Raspberry Pi OS

- Download the latest Raspberry Pi OS Lite from https://www.raspberrypi.org/software/operating-systems/
- After flashing it on an SD card, go to the boot partition and create an empty file called `ssh` (this will enable ssh on the first boot so you can access the Pi headlessly)

### Run the installer

- (Recommended) Change the Pis hostname to something else than raspberry, you can do so by running `# raspi-config`
- (Recommended) Change the default pi password (raspberry), you can do so by running `$ passwd`
- On the Pi, install git: `# apt install git`
- Clone this repository: `$ git clone https://github.com/Czechball/pidrive-install.git`
- Go into its directory and start the first installation script: `$ cd pidrive-install`, `# ./install.sh` (this will take a long time on slow SD cards, over an hour)
- Complete any prompts (mainly the one shown when installing macchanger, select "No") and reboot the Pi when finished
- After the reboot, go to the pidrive-install directory again and start the second installation script: `# ./finalize.sh`

## Getting interfaces ready

- To create a service and exclude a wireless interface from dhcpcd, simply run `# add-interface.sh`
- When interface is added, you should reconnect it to properly initialize systemd services
