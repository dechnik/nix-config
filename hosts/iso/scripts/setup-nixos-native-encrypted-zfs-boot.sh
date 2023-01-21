#!/usr/bin/env bash
VERSION="20220522"

# sudo setup-nixos-native-encrypted-zfs-boot --use-defaults --hostname thinkpad

# This script prepares a NixOS installation:
# - mirrored zfs native encrypted boot

### Change keyboard layout
# setxkbmap us -variant colemak

## SOURCES:
# source_1: 20191024; https://github.com/a-schaefers/themelios
# source_2: 20200624; https://nixos.wiki/wiki/NixOS_on_ZFS
# source_3: 20200626; https://gist.github.com/mannkind/07b21461061e599e1372b2bf8c46a337
# source_4: 20200626; https://gist.github.com/xunil154/e7292db25428a26cdfca4d683a9bcb8d
# source_5: 20200626; https://saveriomiroddi.github.io/Installing-Ubuntu-on-a-ZFS-root-with-encryption-and-mirroring/
# source_6: 20200626; https://github.com/saveriomiroddi/zfs-installer
# source_7: 20200403; https://github.com/bhougland18/nixos_config
# source_8: 20190804; https://elis.nu/blog/2019/08/encrypted-zfs-mirror-with-mirrored-boot-on-nixos/   # Doesn't work, none of the drives are recognized/won't boot.
# source_9: 20190814; https://github.com/johnalotoski/nixos-etc
# source_10: 20190817; https://github.com/bjornfor/nixos-config
# source_11: 20200919; https://wiki.c3d2.de/Diskussion:NixOS
# source_12: 20190704; https://gist.github.com/dysinger/a0031aca70f9dc8df989010c88fc9c27
# source_13: 20200117; https://github.com/eoli3n/nix-config/blob/master/scripts/install
# source_14: 20180624; https://elvishjerricco.github.io/2018/06/24/secure-declarative-key-management.html
# source_15: 20190417; https://hydra.nixos.org/build/115931128/download/1/manual/manual.html#idm140737322649152
# source_16: 20200527; https://gist.github.com/mx00s/ea2462a3fe6fdaa65692fe7ee824de3e


########  PREPARATION  ########
#
#   ## BUILD ISO
# nix build .#iso --impure
# # or if flake.nix is not configured
# nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix
#
#   ## TEST ISO
# mkdir -p ~/test_iso_mount
# sudo mount -o loop -t iso9660 ./result/iso/my-nixos-live.iso ~/test_iso_mount
# sudo umount ~/test_iso_mount && rm -rf ~/test_iso_mount
#
#   ## FIND INSTALLATION DEVICE (eg. /dev/sdX)
# # change 'sdX' to the correct one. eg. 'sdc'
# lsblk
#
#   ## WRITE TO THUMB-DRIVE
# sudo dd bs=4M if=result/iso/my-nixos-live.iso of=/dev/sdX status=progress oflag=sync
# # or ?
# sudo dd bs=4M if=result/iso/my-nixos-live.iso of=/dev/sdX status=progress conv=fsync
#
#   ## LIVEBOOT USB
#  - Select "Installer"
#
#   ## Inside Installer GUI
#  - Run script
# sudo /iso/nixcfg/scripts/setup_nixos_native_encrypted_zfs_boot.sh [hostName]
# sudo /iso/nixcfg/scripts/setup_nixos_native_encrypted_zfs_boot.sh
#
###############################

##TODO: Write a script to replace a mirror drive (boot and zfs)

ARG_HOSTNAME=""
ZFS_POOL_DRIVES=()
ARG_USE_DEFAULTS=false
ARG_FS_TYPE=""
ARG_ZFS_POOL_NAME=""
ARG_ZFS_RESERVED_SIZE=""
ARG_WIPE_DRIVES=""
ARG_SWAP_SIZE=""
ARG_REBOOT_AFTER_INSTALL=false
ARG_POWEROFF_AFTER_INSTALL=false

HOSTNAME_DEFAULT="fresh-install"
RAM_SIZE_GB=$(grep -oP '^MemTotal:\s+\K\d+' /proc/meminfo | numfmt --from=auto --from-unit=1024 --to=iec) # 16G
RAM_SIZE_IN_GB=$(echo "${RAM_SIZE_GB//[a-zA-Z]*/}" | awk '{printf("%d\n",$1 + 0.5)}')
SWAP_RAM_SIZE_EXTRA_GB=4
SWAP_SIZE_DEFAULT=$(( SWAP_RAM_SIZE_EXTRA_GB + RAM_SIZE_IN_GB ))  # IN GB

ZFS_POOL_NAME_DEFAULT="rpool"
ZFS_RESERVED_SIZE_DEFAULT=25 # in GB OR 10% of disk size, whichever is smaller
TS=$(date +"%Y%m%d_%H%M%S")

REMOTE_PING_LOCATION=fsf.org

SRC_NIXCFG_PATH="/etc/nixcfg"

#################################################

L_0EMERGENCY=0
L_1ALERT=1
L_2CRITICAL=2
L_3ERROR=3
L_4WARNING=4
L_5NOTICE=5
L_6INFO=6
L_7DEBUG=7
LOG_LEVEL=$L_5NOTICE

_COLOR_RESET="\033[0m"
_COLOR_START="\033["
_COLOR_END="m"
_NORMAL=0
_BOLD=1
_UNDERLINED=4
_BLINKING=5
_REVERSE_VIDEO=7
_FG_BLACK=30
_FG_RED=31
_FG_GREEN=32
_FG_YELLOW=33
_FG_BLUE=34
_FG_MAGENTA=35
_FG_CYAN=36
_FG_WHITE=37
_BG_BLACK=40
_BG_RED=41
_BG_GREEN=42
_BG_YELLOW=43
_BG_BLUE=44
_BG_MAGENTA=45
_BG_CYAN=46
_BG_WHITE=47

set -euo pipefail
# set -x  # Print all executed commands to the terminal

function usage () {
  printf "%b" "
Setup nixos native encrypted zfs boot.

Usage

  $(basename "${BASH_SOURCE[0]}") [options]

Options:

    -h, --help                        Display this message
        --version                     Show version
    -v, --verbose                     Show what is being done
        --debug                       Show everything that can be shown
        --use-defaults                Use default values, don't ask questions
        --hostname=HOSTNAME           Device's hostname (default: $HOSTNAME_DEFAULT)
        --drive-path=PATH             Drive's path
        --drive-serial=SERIAL         Drive's serial
        --wipe-drives=TYPES           Clean drives: quick | slow | quick+slow (default: quick)
        --zfs-pool-name=NAME          Zfs poolname (default: $ZFS_POOL_NAME_DEFAULT)
        --fs-type=(zfs|native+zfs)    Filesystem type: zfs | native+zfs ## unsupported: luks+zfs (default: zfs)
        --zfs-reserved-size=SIZE      Reserved zfs space in GB (default: $(calculate_default_reserved_size))
        --swap-size=SIZE              Swap size in GB (default: $SWAP_SIZE_DEFAULT)
        --reboot                      Reboot the system after install
        --poweroff                    Poweroff the system after install

Arguments:

"
}

function ask_question () {
  echo -e "\n${_COLOR_START}${_BOLD};${_FG_WHITE};${_BG_GREEN}${_COLOR_END} > $1${_COLOR_RESET}"
}

function ask_question_yn () {
  ask_question "$1" ; read -n 1 -r ; echo
}

function set_log_level () {
  local level=$1
  if [ "$level" -gt $LOG_LEVEL ]; then
    LOG_LEVEL=$level
  fi
}

declare -A LOG_LEVELS
# https://en.wikipedia.org/wiki/Syslog#Severity_level
LOG_LEVELS=([$L_0EMERGENCY]="emerg" [$L_1ALERT]="alert" [$L_2CRITICAL]="crit" [$L_3ERROR]="ERROR" [$L_4WARNING]="warning" [$L_5NOTICE]="notice" [$L_6INFO]="info" [$L_7DEBUG]="debug")
function .log () {
  local level=$1
  shift
  if [ "$LOG_LEVEL" -ge "$level" ]; then
    if [ "$level" == 0 ]; then
      echo -e " ${_COLOR_START}${_BOLD};${_FG_MAGENTA};${_BLINKING};${_UNDERLINED}${_COLOR_END}[${LOG_LEVELS[$level]}] $*${_COLOR_RESET}"
    elif [ "$level" == 1 ]; then
      echo -e " ${_COLOR_START}${_BOLD};${_FG_MAGENTA};${_BLINKING}${_COLOR_END}[${LOG_LEVELS[$level]}] $*${_COLOR_RESET}"
    elif [ "$level" == 2 ]; then
      echo -e " ${_COLOR_START}${_NORMAL};${_FG_MAGENTA}${_COLOR_END}[${LOG_LEVELS[$level]}] $*${_COLOR_RESET}"
    elif [ "$level" == 3 ]; then
      echo -e " ${_COLOR_START}${_NORMAL};${_FG_RED}${_COLOR_END}[${LOG_LEVELS[$level]}] $*${_COLOR_RESET}"
    elif [ "$level" == 4 ]; then
      echo -e " ${_COLOR_START}${_NORMAL};${_FG_WHITE}${_COLOR_END}[${LOG_LEVELS[$level]}] $*${_COLOR_RESET}"
    elif [ "$level" == 5 ]; then
      echo "$@"
    elif [ "$level" == 6 ]; then
      echo -e " ${_COLOR_START}${_NORMAL};${_FG_WHITE}${_COLOR_END}[${LOG_LEVELS[$level]}] $*${_COLOR_RESET}"
    elif [ "$level" == 7 ]; then
      echo -e " ${_COLOR_START}${_NORMAL};${_FG_WHITE}${_COLOR_END}[${LOG_LEVELS[$level]}] $*${_COLOR_RESET}"
    fi
  fi
}

function clear_warning_line () {
  echo -ne "\033[0K\r" # clear warning line
}

function warn_countdown () {
  timeout=$(($1 * 10)) # in seconds
  message=$2
  while [ ${timeout} -gt 0 ]; do
    echo -ne " ${_COLOR_START}${_NORMAL};${_BG_MAGENTA}${_COLOR_END}[WARNING] $message $timeout${_COLOR_RESET}\033[0K\r"
    (( timeout-- ))
    sleep 0.1
  done
  if [ "${3-}" == "clear" ]; then
    clear_warning_line
  else
    echo # show warning line
  fi
}

function selector () {
  local title=$1
  local title_singular="$2"
  local title_plural="$3"
  local zero_choice="${4:-false}"

  .log $L_5NOTICE "$title"
  local selector_amount
  selector_amount=$(echo -e "$selector_items" | wc -l)
  .log $L_7DEBUG "selector_amount: $selector_amount"
  if [ "$selector_amount" == 0 ]; then
    .log $L_4WARNING "no $title_singular found."
    exit 0
  elif [ "$selector_amount" == 1 ]; then
    .log $L_5NOTICE "  $title_singular:"
  else
    .log $L_5NOTICE "  $title_plural:"
  fi
  .log $L_5NOTICE "$(echo -e "$selector_items" | nl)"
  if [ "$zero_choice" = true ]; then
    .log $L_5NOTICE "     0   <done>"
  fi
  while true; do
    ask_question "Enter $title_singular [1-${selector_amount}] " ; read -r selector_chosen_line_nr
    # .log $L_7DEBUG "SELECTOR_CHOSEN_LINE_NR:   $selector_chosen_line_nr"
    if [ "$zero_choice" = true ] && [ "$selector_chosen_line_nr" == 0 ]; then
      break
    elif ! [[ $selector_chosen_line_nr =~ ^[1-9][0-9]*$ ]]; then
      .log $L_4WARNING "invalid input: only positive integers"
    elif [ "$selector_chosen_line_nr" -gt "$selector_amount" ]; then
      .log $L_4WARNING "invalid input: out of range"
    else
      # selector_chosen_item=$(echo -e "$selector_items" | sed -n "${selector_chosen_line_nr}p")
      # .log $L_7DEBUG "SELECTED:   $selector_chosen_item"
      break
    fi
  done
}

function formatTime () {
  printf '%02d:%02d:%02d\n' $(($1 / 3600)) $(($1 % 3600 / 60)) $(($1 % 60))
}

function die () {
  .log $L_2CRITICAL "$*"
  exit 1
}

function uefi_or_legacy () {
  UEFI_INSTALL=false
  [ -d "/sys/firmware/efi/efivars" ] && UEFI_INSTALL=true
  if [ "$UEFI_INSTALL" = true ]; then
    .log $L_5NOTICE "Mode: UEFI"
    .log $L_5NOTICE " SINGLE DRIVE:           /boot           : OK"
    # .log $L_5NOTICE " SINGLE DRIVE:           /boot1          : failed"
    .log $L_5NOTICE " SINGLE DRIVE with Swap: /boot           : failed : installs but won't boot ; importing root ZFS pool ..... ;"
    .log $L_4WARNING "UEFI is unreliable for mirrored boot. PLEASE USE LEGACY BIOS."

    # MIRROR: If you really want to use uefi, it will install and boot. BUT if you disconnect one of the mirrors and connect/disconnect and switch them. Eventually you'll get an error.
    #  "Press ESC in 1 seconds to skip startup.nsh, any other key to continue."
    #  You can 'fix/overcome' this error by booting in legacy BIOS mode.
    #  Please use Legacy Bios from the start. It will work with zfs mirror.
  else
    .log $L_5NOTICE "Mode: Legacy BIOS"
    .log $L_5NOTICE " SINGLE DRIVE:           /boot           : OK"
    # .log $L_5NOTICE " SINGLE DRIVE:           /boot1          : failed"
    .log $L_5NOTICE " SINGLE DRIVE with Swap: /boot           : failed : installs but won't boot ; importing root ZFS pool ..... ;"
    .log $L_5NOTICE " MIRROR DRIVE:           /boot1 /boot2   : OK"
  fi
}

function check_network_connection () {
  if ping -c 1 $REMOTE_PING_LOCATION &> /dev/null; then
    .log $L_5NOTICE "Network Connection OK (reached: \"${REMOTE_PING_LOCATION}\")"
  else
    .log $L_4WARNING "Connection failed"
    ask_question_yn "Configure Wireless Connection? <y/N> "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      .log $L_5NOTICE " Setup wireless connection:"
      .log $L_5NOTICE " All Nearby Visible SSID:"
      nmcli dev wifi rescan && nmcli dev wifi
      # wpa_cli scan_results
      ask_question "Enter your SSID " ; read -r SSID
      .log $L_5NOTICE "  >> SSID=$SSID"
      ask_question " Enter your passphrase " ; read -s -r PASSPHRASE
      wpa_passphrase "$SSID" "$PASSPHRASE" > /etc/wpa_supplicant.conf
      systemctl restart wpa_supplicant.service

      if ping -c 1 $REMOTE_PING_LOCATION &> /dev/null; then
        .log $L_5NOTICE "Connection succes (reached: \"${REMOTE_PING_LOCATION}\")"
        ##TODO: Question: add this wifi network to the config?
      else
        .log $L_3ERROR "Connection failed: Failed to setup wireless connection"
      fi
    fi
  fi
}

function select_hostname () {
  local hostnames
  hostnames=$(find "${SRC_NIXCFG_PATH}/hosts/" -mindepth 1 -maxdepth 1 -type d \( ! -iname ".*" \) | sed 's|^\./||g' | xargs -l basename | sort)

  if [ -n "$ARG_HOSTNAME" ]; then
    # use the supplied hostname
    SELECTED_HOSTNAME="$ARG_HOSTNAME"
  elif [ "$ARG_USE_DEFAULTS" = true ]; then
    SELECTED_HOSTNAME="$HOSTNAME_DEFAULT"
  else
    selector_items="$hostnames"
    selector "Select Hostname:" "Host" "Hosts"
    local selector_chosen_item
    selector_chosen_item=$(echo -e "$hostnames" | sed -n "${selector_chosen_line_nr}p")
    .log $L_7DEBUG "selector_chosen_item: $selector_chosen_item"
    SELECTED_HOSTNAME=$selector_chosen_item
    ##TODO: (0 = enter new hostname) ;
  fi
  # Check selected hostname exists in hosts
  hostname_match=$(echo -e "$hostnames" | grep "^${SELECTED_HOSTNAME}$" || true; echo)
  [ ! "$hostname_match" ] && .log $L_3ERROR "Unknown hostname" && exit 1
  ##TODO: in case new hostname, Ask question: "which category_template? (desktop, server, vm, router, ...)"

  .log $L_5NOTICE " hostname = <$SELECTED_HOSTNAME>"
}

function add_drive_to_pool_by_id_path () {
  local drive_id_path
  drive_id_path=$1
  if [[ "\ ${ZFS_POOL_DRIVES[*]}\ " =~ \ $drive_id_path\  ]]; then
    .log $L_4WARNING "Drive was already selected (${drive_id_path})"
  else
    ## ZFS_POOL_DRIVES=("/dev/disk/by-id/ata-CT1000MX500SSD1_1902E1E1D0B7" "/dev/disk/by-id/ata-CT1000MX500SSD1_1920E2047C3F") # Note: using /dev/disk/by-id is also preferable.
    ## Always use the by-id aliases for devices, otherwise ZFS can choke on imports.
    ## Note: using /dev/disk/by-id is also preferable.
    ZFS_POOL_DRIVES+=("$drive_id_path")
    .log $L_7DEBUG "  drive_${#ZFS_POOL_DRIVES[@]}: ${ZFS_POOL_DRIVES[-1]}"
    ##TODO: show drive_path , drive_serial , drive_id_path
  fi
}

function add_drive_to_pool_by_serial () {
  local drive_serial drive_id_path
  drive_serial=$1
  drive_id_path=$(find /dev/disk/by-id/ -mindepth 1 -maxdepth 1 -name "*$drive_serial*" | sort | head -n1)
  .log $L_7DEBUG " add_drive_to_pool_by_serial: ${drive_serial}  >  ${drive_id_path}"
  add_drive_to_pool_by_id_path "$drive_id_path"
}

function add_drive_to_pool_by_path () {
  local drive_path drive_serial
  drive_path=$1
  drive_serial=$(lsblk -n -o path,serial | grep "${drive_path} " | awk '{print $2}')
  .log $L_7DEBUG " add_drive_to_pool_by_path: ${drive_path}  >  ${drive_serial}"
  add_drive_to_pool_by_serial "$drive_serial"
}

function select_boot_drives () {
  if [ -z "${ZFS_POOL_DRIVES[*]}" ]; then
    while true; do
      # Choose a connected drive.
      local connected_drives
      connected_drives=$(lsblk -n -d -S -o model,serial,size,name,path,state)
      selector_items=$connected_drives

      .log $L_5NOTICE " ZFS_POOL_DRIVES: ${ZFS_POOL_DRIVES[*]}"
      local next_drive_number
      next_drive_number=$((${#ZFS_POOL_DRIVES[@]}+1))
      selector "Enter Boot drive   > ${next_drive_number} <:" "Drive" "Drives" true
      if [ "${selector_chosen_line_nr}" == 0 ]; then
        if [ ${#ZFS_POOL_DRIVES[@]} == 0 ]; then
          .log $L_4WARNING "You have to select at least 1 drive"
        else
          break
        fi
      else
        local selector_chosen_item
        selector_chosen_item=$(echo -e "$connected_drives" | sed -n "${selector_chosen_line_nr}p")
        .log $L_7DEBUG "selector_chosen_item: $selector_chosen_item"
        chosen_serial=$(echo -e "$selector_chosen_item" | awk '{print $2}')
        add_drive_to_pool_by_serial "$chosen_serial"
      fi
    done
  fi
  for drive_id_path in "${ZFS_POOL_DRIVES[@]}"; do
    # print_drive_partitioning
    .log $L_7DEBUG "  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄  ⌄"
    .log $L_7DEBUG "$(sgdisk -p "$drive_id_path")"
    .log $L_7DEBUG "  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  ^"
  done
  ZFS_POOL_TYPE="" ## use "" for single, or "mirror", "raidz1", etc.
  if [ ${#ZFS_POOL_DRIVES[@]} -ge 2 ]; then
     ZFS_POOL_TYPE="mirror"
    .log $L_5NOTICE " DRIVES: ${ZFS_POOL_DRIVES[*]}"
  else
    .log $L_4WARNING "Single drive installation"
    .log $L_5NOTICE " DRIVE: ${ZFS_POOL_DRIVES[*]}"
  fi
}

function question_wipe_drives_quick () {
  _positive () {
    USE_ZPOOL_DESTROY=true
    USE_SGDISK_CLEAR=true
    USE_WIPEFS_ALL=true
  }
  _negative () {
    USE_ZPOOL_DESTROY=false
    USE_SGDISK_CLEAR=false
    USE_WIPEFS_ALL=false
  }
  allowed_value="QUICK"
  if [[ ${ARG_WIPE_DRIVES^^} =~ (^|.*\+)$allowed_value(\+.*|$) ]]; then
    _positive
  elif [ "$ARG_USE_DEFAULTS" = true ]; then
    _positive
  else
    ask_question_yn "Use \"zpool destroy\" and \"sgdisk --clear\" and \"wipefs --all\"? <Y/n> "
    if [[ $REPLY =~ ^[Nn]$ ]]; then
      _negative
    else
      _positive
    fi
  fi
  .log $L_5NOTICE " wipe_drives_quick = <$USE_SGDISK_CLEAR>"
}

function question_wipe_drives_slow () {
  _positive () {
    USE_ZERO_DRIVES=true
  }
  _negative () {
    USE_ZERO_DRIVES=false
  }
  allowed_value="SLOW"
  if [[ ${ARG_WIPE_DRIVES^^} =~ (^|.*\+)$allowed_value(\+.*|$) ]]; then
    _positive
  elif [ "$ARG_USE_DEFAULTS" = true ]; then
    _negative
  else
    ask_question_yn "Use slow/complete dd /dev/zero? <y/N> "
    # use dd if=/dev/zero ... 'ALL/FULL/ drive dd'
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      _positive
    else
      _negative
    fi
  fi
  .log $L_5NOTICE " wipe_drives_slow = <$USE_ZERO_DRIVES>"
}

function question_zfs_pool_name () {
  if [ -n "$ARG_ZFS_POOL_NAME" ]; then
    ZFS_POOL_NAME="$ARG_ZFS_POOL_NAME"
  elif [ "$ARG_USE_DEFAULTS" = true ]; then
    ZFS_POOL_NAME="$ZFS_POOL_NAME_DEFAULT"
  else
    ask_question_yn "Use boot ZFS_POOL_NAME: <$ZFS_POOL_NAME_DEFAULT>? <Y/n> "
    if [[ $REPLY =~ ^[Nn]$ ]]; then
      ask_question "Enter a ZFS_POOL_NAME " ; read -r
      ZFS_POOL_NAME="$REPLY"
    else
      ZFS_POOL_NAME="$ZFS_POOL_NAME_DEFAULT"
    fi
  fi
  .log $L_5NOTICE " zfs_pool_name = <${ZFS_POOL_NAME}>"

  # ephemeral datasets
  zfs_local="${ZFS_POOL_NAME}/local"
  zfs_ds_root="${zfs_local}/root"
  zfs_ds_nix="${zfs_local}/nix"
  zfs_ds_cache="${zfs_local}/cache"

  # persistent datasets
  zfs_safe="${ZFS_POOL_NAME}/safe"
  zfs_ds_home="${zfs_safe}/home"
  zfs_ds_persist="${zfs_safe}/persist"
  zfs_ds_ssync="${zfs_safe}/ssync"
}

function question_zfs_native_encryption () {
  if [ "$ARG_FS_TYPE" == "native+zfs" ]; then
    USE_ZFS_POOL_ENCRYPTION=true
  elif [ "$ARG_FS_TYPE" == "zfs" ]; then
    USE_ZFS_POOL_ENCRYPTION=false
  elif [ "$ARG_USE_DEFAULTS" = true ]; then
    USE_ZFS_POOL_ENCRYPTION=false
  else
    ask_question_yn "Use ZFS Native Encryption? <Y/n> "
    if [[ $REPLY =~ ^[Nn]$ ]]; then
      USE_ZFS_POOL_ENCRYPTION=false
    else
      USE_ZFS_POOL_ENCRYPTION=true
    fi
  fi
  .log $L_5NOTICE " zfs_native_encryption = <$USE_ZFS_POOL_ENCRYPTION>"
}

function calculate_default_reserved_size () {
  # if zfs reserved is bigger than 10% of the smallest disk, just use 10%.
  local smallest_disk_size
  smallest_disk_size=""
  for drive_id in "${ZFS_POOL_DRIVES[@]}"; do
    disk_size_in_bytes=$(lsblk -b --output SIZE -n -d "$drive_id")
    disk_size_in_gb=$((disk_size_in_bytes/1024/1024/1024))
    if [ -z "$smallest_disk_size" ] || [[ "$smallest_disk_size" > "$disk_size_in_gb" ]]; then
      smallest_disk_size=$disk_size_in_gb
    fi
  done
  disk_size_10_percent=$((smallest_disk_size/10))

  if [[ "$ZFS_RESERVED_SIZE_DEFAULT" > "$disk_size_10_percent" ]]; then
    echo $disk_size_10_percent
  else
    echo $ZFS_RESERVED_SIZE_DEFAULT
  fi
}

function question_zfs_reserved_size () {
  _no_reserved_size () {
    .log $L_5NOTICE "  > > No reserved space"
    ZFS_RESERVED_SIZE=""
  }
  _default_reserved_size () {
    ZFS_RESERVED_SIZE=$(calculate_default_reserved_size)
    .log $L_5NOTICE "  > > Using default: zfs_reserved_size = <$(calculate_default_reserved_size)GB>"
  }

  if [ -n "$ARG_ZFS_RESERVED_SIZE" ]; then
    ZFS_RESERVED_SIZE="$ARG_ZFS_RESERVED_SIZE"
  elif [ "$ARG_USE_DEFAULTS" = true ]; then
    _default_reserved_size
  else
    ask_question "Enter ZFS RESERVED SIZE in GB, default=$(calculate_default_reserved_size)GB (no_reserved_space: 0) " ; read -r ZFS_RESERVED_SIZE
    if [[ $ZFS_RESERVED_SIZE =~ ^[0]+$ ]]; then
      _no_reserved_size
    elif ! [[ $ZFS_RESERVED_SIZE =~ ^[0-9]+([.][0-9]+)?$ ]]; then
      _default_reserved_size
    fi
  fi
  .log $L_5NOTICE " zfs_reserved_size = <${ZFS_RESERVED_SIZE}GB>"
}

function question_swap_size () {
  _no_swap () {
    .log $L_5NOTICE "  > > No swap partition"
    SWAP_SIZE=""
  }
  _default_swap () {
    SWAP_SIZE=$SWAP_SIZE_DEFAULT
    .log $L_5NOTICE "  > > Using default: swap_size = <${SWAP_SIZE}GB>"
  }
  .log $L_5NOTICE "System RAM size = $RAM_SIZE_GB"
  if [ -n "$ARG_SWAP_SIZE" ]; then
    SWAP_SIZE="$ARG_SWAP_SIZE"
  elif [ "$ARG_USE_DEFAULTS" = true ]; then
    _no_swap
  else
    ask_question "Enter swap_size in GB, default=${SWAP_SIZE_DEFAULT}GB (no_swap_partition: 0) " ; read -r SWAP_SIZE
  fi
  if [[ $SWAP_SIZE =~ ^[0]+$ ]]; then
    _no_swap
  elif ! [[ $SWAP_SIZE =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    _default_swap
  fi
  .log $L_5NOTICE " swap_size = <${SWAP_SIZE}GB>"
}

function show_all_chosen_settings () {
  .log $L_4WARNING "   # # Chosen Settings # #"
  .log $L_4WARNING " hostname = <$SELECTED_HOSTNAME>"
  .log $L_4WARNING " uefi_install = <$UEFI_INSTALL>"
  .log $L_4WARNING " wipe_drives_quick = <$USE_SGDISK_CLEAR>"
  .log $L_4WARNING " wipe_drives_slow = <$USE_ZERO_DRIVES>"
  .log $L_4WARNING " zfs_pool_name = <${ZFS_POOL_NAME}>"
  .log $L_4WARNING " zfs_native_encryption = <$USE_ZFS_POOL_ENCRYPTION>"
  .log $L_4WARNING " zfs_reserved_size = <${ZFS_RESERVED_SIZE}GB>"
  # .log $L_4WARNING " swap_size = <${SWAP_SIZE}GB>"
}

function drive_prep () {
  .log $L_5NOTICE "Drive Preparation:"
  BOOT_PARTITION="-part2"
  SWAP_PARTITION="-part3"
  ZPOOL_PARTITION="-part4"
  # use_sdX=""
  # use_nvme=""
  # # some initial translation for whether or not the script was provided drives with sd* or /dev/disk/by-id/*, etc.
  # echo "${ZFS_POOL_DRIVES[0]}" | grep -q "/dev/disk/by-id/ata-" && use_sdX="1"
  # echo "${ZFS_POOL_DRIVES[0]}" | grep -q "/dev/disk/by-id/nvme-" && use_nvme="1"
  # ##TODO: Currently only support for 1 technology at a time (nvme, sata)
  # if [ ${use_sdX:-} ]; then
  #   BOOT_PARTITION="-part2"
  #   SWAP_PARTITION="-part3"
  #   ZPOOL_PARTITION="-part4"
  # elif [ ${use_nvme:-} ]; then # fixes https://github.com/a-schaefers/themelios/issues/2
  #   BOOT_PARTITION="p2"
  #   SWAP_PARTITION="p3"
  #   ZPOOL_PARTITION="p4"
  # else
  #   BOOT_PARTITION="2"
  #   SWAP_PARTITION="3"
  #   ZPOOL_PARTITION="4"
  # fi

  zpool_destroy () {
    ##TODO: Does this fix the error??: during zpool create, already created..
    ##TODO: This happens when we: boot usb / run this script past zpool and mounting.. / rerun this script
    ##TODO: Useful during a rerun
    existing_pool=$(zpool list -Ho name | grep "${ZFS_POOL_NAME}" || true; echo)
    if [ -n "$existing_pool" ]; then
      .log $L_5NOTICE " Destroying pool...:"
      sudo zpool destroy -f "${ZFS_POOL_NAME}" || true
      sudo umount "/mnt/boot" || true
      sudo umount "/mnt/boot1" || true
      sudo umount "/mnt/boot2" || true
      sudo umount "/mnt" || true
      sudo zpool destroy -f "${ZFS_POOL_NAME}" || true
    fi
    sleep 2
  }
  [ "$USE_ZPOOL_DESTROY" = true ] && zpool_destroy

  sgdisk_clear () {
    for drive_id in "${ZFS_POOL_DRIVES[@]}"; do
      .log $L_5NOTICE " Clearing drive with sgdisk..."
      sgdisk --zap-all "$drive_id" || true
    done
    sleep 2
  }
  [ "$USE_SGDISK_CLEAR" = true ] && sgdisk_clear

  wipefs_all () {
    .log $L_7DEBUG "    yyyyyyyyyy 11111 aaaaa"
    for drive_id in "${ZFS_POOL_DRIVES[@]}"; do
      .log $L_7DEBUG "    yyyyyyyyyy 11111 aaaaa xxx"
      .log $L_5NOTICE " Wiping drive signatures with wipefs..."
      .log $L_7DEBUG "    yyyyyyyyyy 11111 aaaaa yyy"
      sudo wipefs -fa "$drive_id" || true
      .log $L_7DEBUG "    yyyyyyyyyy 11111 aaaaa zzz"
    done
    .log $L_7DEBUG "    yyyyyyyyyy 11111 bbbbbb"
    sleep 2
  }
  .log $L_7DEBUG "    yyyyyyyyyy 11111"
  [ "$USE_WIPEFS_ALL" = true ] && wipefs_all
  .log $L_7DEBUG "    yyyyyyyyyy 22222"

  dd_zero () {
    for drive_id in "${ZFS_POOL_DRIVES[@]}"; do
      .log $L_5NOTICE " Writing zeros to ${drive_id}..."
      dd if=/dev/zero of="$drive_id" bs=1M oflag=direct status=progress &
    done
    wait
  }
  .log $L_7DEBUG "    yyyyyyyyyy 333333"
  [ "$USE_ZERO_DRIVES" = true ] && dd_zero
  .log $L_7DEBUG "    yyyyyyyyyy 4444444"
}

function partition_drive () {
  .log $L_7DEBUG "    yyyyyyyyyy 555555"
  sleep 2
  .log $L_7DEBUG "    yyyyyyyyyy 666666"
  for drive_id in "${ZFS_POOL_DRIVES[@]}"; do
    .log $L_7DEBUG "    yyyyyyyyyy 666666 aaaaaaa"
    .log $L_5NOTICE "Drive Partitioning: ${drive_id}"
    .log $L_7DEBUG "    yyyyyyyyyy 666666 bbbbbbbb"
    sgdisk -og "$drive_id"
    .log $L_7DEBUG "    yyyyyyyyyy 666666 cccccccc"
    .log $L_5NOTICE " Making bios boot partition..."
    sgdisk -a 1 -n 1:48:2047 -t 1:EF02 -c 1:"BIOS Boot Partition" "$drive_id" || die "partition_drive failed"
    partx -u "$drive_id"
    .log $L_5NOTICE " Making 1G /boot fat32 ESP..."
    sgdisk -n 2:4096:2101247 -c 2:"Fat32 ESP Partition" -t 2:EF00 "$drive_id" || die "partition_drive failed"
    partx -u "$drive_id"
    if [ ${#ZFS_POOL_DRIVES[@]} == 1 ] && [ -n "$SWAP_SIZE" ]; then
      # For a single-drive install
      sgdisk -n 3:0:+"${SWAP_SIZE}"GiB -c 3:swap -t 3:8200 "$drive_id" || die "partition_drive failed"
      ##TODO: Can we make mirrored swap work, randomEncrypted
      # # For a mirror or raidz topology
      # sgdisk -n 3:0:+"${SWAP_SIZE}"GiB -c 3:swap -t 3:FD00 "$drive_id" || die "partition_drive failed"
    fi
    .log $L_5NOTICE " Making zpool partition with remainder of space..."
    sgdisk -n 4:0:0 -c 4:"ZPOOL Partition" -t 4:BF01 "$drive_id" || die "partition_drive failed" ##TODO: 8300(Linux filesystem) vs BF01(Solaris /usr & Mac Z)
    sgdisk -p "$drive_id" || die "partition_drive failed"
    partx -u "$drive_id"
    sleep 5 # workaround weird issue where Linux still needs some time after partx to resolve drive path
  done
  .log $L_7DEBUG "    yyyyyyyyyy 7777777"
}

function recursive_dividing_by_2 () {
  if (( $1 <= 1 )); then
    echo 0
  else
    last=$(recursive_dividing_by_2 $(( $1 / 2 )))
    echo $(( last + 1 ))
  fi
}

function calculate_zfs_ashift () {
  # For example, 4096k => ashift=12.
  biggest_ashift=""
  for drive_id in "${ZFS_POOL_DRIVES[@]}"; do
    blocksize=$(sudo blockdev --getbsz "$drive_id")
    .log $L_7DEBUG "  blocksize = ${blocksize}"
    ashift=$(recursive_dividing_by_2 "$blocksize")
    .log $L_7DEBUG "  ashift = ${ashift}"
    if [ -z "$biggest_ashift" ] || [[ "$biggest_ashift" < "$ashift" ]]; then
      biggest_ashift=$ashift
    fi
  done
  ZFS_ASHIFT="-o ashift=${biggest_ashift}"
  .log $L_5NOTICE "  zfs_ashift = ${biggest_ashift}"
}

function zpool_create () {
  .log $L_5NOTICE "Create zpool: ${ZFS_POOL_NAME}"

  calculate_zfs_ashift

  zfs_pool_encryption=""
  if [ "$USE_ZFS_POOL_ENCRYPTION" = true ]; then
    zfs_pool_encryption="-O encryption=aes-256-gcm -O keyformat=passphrase"
    .log $L_4WARNING " Enter ZFS passphrase to unencrypt at boot:   >> MINIMUM 8 CHARACTERS) << "
  fi
  ##TODO: Make this loop if the creating is failing because of the passphrase.

  # Some flags to consider
  # Disable ZFS automatic mounting, we'll use the normal fstab-based mounting:
  #   -O mountpoint=none
  # Disable writing access time, disables if a file's access time is updated when the file is read. This can result in significant performance gains, but might confuse some software like mailers.
  #   -O atime=off
  # Use 4K sectors on the drive, otherwise you can get really bad performance:
  #   -o ashift=12
  # This is more or less required for certain things to not break, for systemd-journald posixacls are required:
  #   -O acltype=posixacl
  # To improve performance of certain extended attributes:
  #   -O xattr=sa
  # To enable filesystem compression:
  #   -O compression=lz4
  #   # zstd is slower but compresses more than lz4
  #   -O compression=zstd
  # To enable encryption:
  #   -O encryption=aes-256-gcm -O keyformat=passphrase
  # 'altroot="/mnt"' is not a persistent property of the FS, it'll just be used while we're installing.
  # 'altroot="/mnt"'    ==    'altroot=/mnt'    ==    '-R /mnt'
  #   -o altroot="/mnt"
  (set -x; zpool create -f \
    ${ZFS_ASHIFT} \
    -O compression=lz4 \
    -O atime=off \
    -O relatime=on \
    -O normalization=formD \
    -O xattr=sa \
    ${zfs_pool_encryption} \
    -m none \
    -R /mnt \
    ${ZFS_POOL_NAME} \
    ${ZFS_POOL_TYPE} \
    ${ZFS_POOL_DRIVES[@]/%/$ZPOOL_PARTITION} || die "zpool_create failed")
  # https://github.com/NixOS/nixpkgs/issues/16954
  zfs set acltype=posixacl "${ZFS_POOL_NAME}"
}

function configure_and_mount_partitions () {
  .log $L_5NOTICE "Configure & Mount partitions:"

  if [ -n "$ZFS_RESERVED_SIZE" ]; then
    # Reserved space: Can be temporaryily used/deleted to fix a full/locked zfs.
    # zfs set refreservation=none rpool/reserved
    .log $L_5NOTICE " ZFS: ${ZFS_POOL_NAME}/reserved"
    zfs create -o refreservation="${ZFS_RESERVED_SIZE}"G -o mountpoint=none "${ZFS_POOL_NAME}/reserved"
  fi

  # / (root) datasets
  .log $L_5NOTICE " ZFS: ${zfs_ds_root}"
  zfs create -p -o mountpoint=legacy "${zfs_ds_root}"
  zfs snapshot "${zfs_ds_root}@blank"
  mount -t zfs "${zfs_ds_root}" /mnt
  # zpool set bootfs="${ZFS_POOL_NAME}/ROOT/nixos" "${ZFS_POOL_NAME}"

  # 1G /boot fat32 ESP
  sleep 5 # workaround weird issue where Linux needs some time after partioning and before mkfs.vfat
  .log $L_5NOTICE " BOOT:"
  if [ ${#ZFS_POOL_DRIVES[@]} -ge 2 ]; then
    bootnum="1" # mirror
  else
    bootnum="" # single
  fi
  .log $L_7DEBUG "  bootnum: <$bootnum>"
  for drive_id in "${ZFS_POOL_DRIVES[@]}"; do
    .log $L_5NOTICE "  Mounting '${drive_id}${BOOT_PARTITION}' to /mnt/boot${bootnum}"
    mkfs.vfat -F32 "${drive_id}${BOOT_PARTITION}" || die "mount_boots mkfs.vfat failed"
    mkdir -p "/mnt/boot${bootnum}"
    mount -t vfat "${drive_id}${BOOT_PARTITION}" "/mnt/boot${bootnum}"
    if [ ${#ZFS_POOL_DRIVES[@]} -ge 2 ]; then
      ((bootnum++))
    fi
  done

  if [ ${#ZFS_POOL_DRIVES[@]} == 1 ] && [ -n "$SWAP_SIZE" ]; then
    .log $L_5NOTICE " SWAP: ${ZFS_POOL_DRIVES[0]}${SWAP_PARTITION}"
    mkswap -L swap "${ZFS_POOL_DRIVES[0]}${SWAP_PARTITION}"
    # NOTE: swapon: otherwise, nixos-install won't generate hardware config for this
    swapon "${ZFS_POOL_DRIVES[0]}${SWAP_PARTITION}"

    ##TODO: make swap work with mirrored drives
    # # mdadm --create swap --level=1 --raid-devices=2 missing /dev/sdb3
    # # mkswap /dev/md/swap
    # # mdadm /dev/md/swap -a /dev/sda3
  fi

  # mount /nix outside of the root dataset
  .log $L_5NOTICE " ZFS: ${zfs_ds_nix}"
  zfs create -p -o mountpoint=legacy "${zfs_ds_nix}"
  .log $L_5NOTICE "  Disabling access time setting for '${zfs_ds_nix}' ZFS dataset ..."
  zfs set atime=off "${zfs_ds_nix}"
  mkdir -p /mnt/nix
  mount -t zfs "${zfs_ds_nix}" /mnt/nix

  .log $L_5NOTICE " ZFS: ${zfs_ds_cache}"
  zfs create -p -o mountpoint=legacy "${zfs_ds_cache}"
  mkdir -p /mnt/cache
  mount -t zfs "${zfs_ds_cache}" /mnt/cache

  .log $L_5NOTICE " ZFS: ${zfs_ds_home}"
  zfs create -p -o mountpoint=legacy "${zfs_ds_home}"
  mkdir -p /mnt/home
  mount -t zfs "${zfs_ds_home}" /mnt/home

  .log $L_5NOTICE " ZFS: ${zfs_ds_persist}"
  zfs create -p -o mountpoint=legacy "${zfs_ds_persist}"
  mkdir -p /mnt/persist
  mount -t zfs "${zfs_ds_persist}" /mnt/persist

  .log $L_5NOTICE " ZFS: ${zfs_ds_ssync}"
  zfs create -p -o mountpoint=legacy "${zfs_ds_ssync}"
  mkdir -p /mnt/ssync
  mount -t zfs "${zfs_ds_ssync}" /mnt/ssync

  .log $L_5NOTICE " Permit ZFS auto-snapshots on ${zfs_safe}/* datasets ..."
  zfs set com.sun:auto-snapshot=true "$zfs_ds_home"
  zfs set com.sun:auto-snapshot=true "$zfs_ds_persist"
  zfs set com.sun:auto-snapshot=true "$zfs_ds_ssync"
}

function copy_nixcfg () {
  .log $L_5NOTICE "Copy nixcfg to: /mnt/ssync"
  mkdir -p "/mnt/ssync"
  cp -r "$SRC_NIXCFG_PATH" "/mnt/ssync/"
  chown 1000:100 -R "/mnt/ssync"
  chmod +w -R "/mnt/ssync"
  cd "/mnt/ssync/nixcfg"
  git init . && git add . && git commit --allow-empty -m "Initialize repository"
}

function new_hostname_from_template () {
  .log $L_5NOTICE "New_hostname_from_template: #TODO"
  ##TODO: a new hostname means:
  # NOTE: use templates, these are easier to keep updated
  # - copy template to nixcfg/hosts/${SELECTED_HOSTNAME}
  #   + rename/change  './hosts/${SELECTED_HOSTNAME}'

  # - modify/update nixcfg/flake.nix
}

function generate_boot_loader_nix () {
  path="${1}"
  .log $L_5NOTICE "Generate ${path}/boot-loader.nix"
  host_id=$(head -c 8 /etc/machine-id)

  cat << EOF > "${path}/boot-loader.nix"
# ${TS}; This was generated by ‘${0}’
## uefi single: OK (afterwards Also boots in bios-mode)
## bios single: Ok (afterwards Doesn't show in uefi-mode)
## uefi mirror: ok, but won't boot if one is missing? why? fix?
## bios mirror: OK
{ ... }:
{
  # Use the GRUB 2 boot loader.
  boot.loader = {
$(if [ "$UEFI_INSTALL" = true ]; then # reinstall in legacy mode??
cat <<- UEFI
  efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot"; # use the same mount point here.
  };
UEFI
fi)
  grub = {
    enable = true;
    version = 2;
    # efiInstallAsRemovable = true;
    # Prevents boot error: external pointer tables not supported. This happens when: ZFS root file system + The number of hardlinks in the nix store gets very high.
    copyKernels = true;
    zfsSupport = true;
$(if [ "$UEFI_INSTALL" = true ]; then
cat <<- UEFI
    efiSupport = true;
UEFI
fi)
$(if [ ${#ZFS_POOL_DRIVES[@]} -ge 2 ]; then
cat <<- MIRROREDBOOTS
    mirroredBoots = [
$(bootnum="1"
for drive_id in "${ZFS_POOL_DRIVES[@]}"; do
echo "        { devices = [ \"${drive_id}\" ]; path = \"/boot${bootnum}\"; }"
((bootnum++))
done)
    ];
MIRROREDBOOTS
else
cat <<- SINGLEBOOT
    devices = [
$(for drive_id in "${ZFS_POOL_DRIVES[@]}"; do
echo "        \"$drive_id\""
done)
    ];
SINGLEBOOT
fi)
  };
  };
  boot.zfs.requestEncryptionCredentials = ${USE_ZFS_POOL_ENCRYPTION};
  fileSystems."/" = {
  neededForBoot = true;
  };
  fileSystems."/nix" = {
  neededForBoot = true;
  };
  fileSystems."/persist" = {
  neededForBoot = true;
  };
  fileSystems."/ssync" = {
  neededForBoot = true;
  };
  fileSystems."/cache" = {
  neededForBoot = true;
  };
$(if [ ${#ZFS_POOL_DRIVES[@]} -ge 2 ]; then
bootnum="1"
for drive_id in "${ZFS_POOL_DRIVES[@]}"; do
cat <<- MIRROREDBOOTS
  fileSystems."/boot${bootnum}" = {
  # nofail: Makes it possible to boot with only 1 mirror present.
  options = [ "nofail" ]; # https://discourse.nixos.org/t/nixos-on-mirrored-ssd-boot-swap-native-encrypted-zfs/9215/6
  };
MIRROREDBOOTS
((bootnum++))
done
fi)
  networking.hostId = "${host_id}"; # The primary use case is to ensure when using ZFS that a pool isn't imported accidentally on a wrong machine.
}
EOF
  nixpkgs-fmt "${path}/boot-loader.nix"
}

function generate_hardware_configuration_nix () {
  path="${1}"
  .log $L_5NOTICE "Generate ${path}/hardware-configuration.nix"
  nixos-generate-config --root /mnt --show-hardware-config > "${path}/hardware-configuration.nix" || die "nixos-generate-config failed"
  nixpkgs-fmt "${path}/hardware-configuration.nix"
}

function installation_complete () {
  cat << EOF
  nnnnnnnn        nnnnnnnn iiiiiiiiii xxxxxxx       xxxxxxx
  n:::::::n       n::::::n i::::::::i x:::::x       x:::::x
  n::::::::n      n::::::n i::::::::i x:::::x       x:::::x
  n:::::::::n     n::::::n ii::::::ii x::::::x     x::::::x
  n::::::::::n    n::::::n   i::::i   xxx:::::x   x:::::xxx
  n:::::::::::n   n::::::n   i::::i      x:::::x x:::::x
  n:::::::n::::n  n::::::n   i::::i       x:::::x:::::x
  n::::::n n::::n n::::::n   i::::i        x:::::::::x
  n::::::n  n::::n:::::::n   i::::i        x:::::::::x
  n::::::n   n:::::::::::n   i::::i       x:::::x:::::x
  n::::::n    n::::::::::n   i::::i      x:::::x x:::::x
  n::::::n     n:::::::::n   i::::i   xxx:::::x   x:::::xxx
  n::::::n      n::::::::n ii::::::ii x::::::x     x::::::x
  n::::::n       n:::::::n i::::::::i x:::::x       x:::::x
  n::::::n        n::::::n i::::::::i x:::::x       x:::::x
  nnnnnnnn         nnnnnnn iiiiiiiiii xxxxxxx       xxxxxxx
EOF
  zfs list

  .log $L_5NOTICE "device's ssh.pub: $(cat /mnt/etc/ssh/ssh_host_ed25519_key.pub)"

  .log $L_5NOTICE "Unmounting /mnt"
  umount -lR /mnt

  if [ ${#ZFS_POOL_DRIVES[@]} == 1 ] && [ -n "$SWAP_SIZE" ]; then
    .log $L_5NOTICE "Swapoff"
    swapoff -a
  fi

  .log $L_5NOTICE "Exporting ${ZFS_POOL_NAME}"
  zpool export "${ZFS_POOL_NAME}"

  if [ "$ARG_REBOOT_AFTER_INSTALL" = true ]; then
    systemctl reboot
  elif [ "$ARG_POWEROFF_AFTER_INSTALL" = true ]; then
    systemctl poweroff
  elif [ "$ARG_USE_DEFAULTS" = false ]; then
    ask_question_yn "finished. reboot now? <Y/n> "
    [[ ! $REPLY =~ ^[Nn]$ ]] && systemctl reboot
  fi
}

function _main () {
  # uuid: (the single colon means the option has a required argument, double colon means optional https://www.bahmanm.com/2015/01/command-line-options-parse-with-getopt.html)
  if ! OPTS=$(getopt -o vh --long debug,verbose,version,help,nixcfg-path:,use-defaults,hostname:,drive-path:,drive-serial:,wipe-drives:,zfs-pool-name:,fs-type:,zfs-reserved-size:,swap-size:,reboot,poweroff -n 'parse-options' -- "$@"); then echo "Failed parsing options." >&2 ; exit 1 ; fi
  eval set -- "$OPTS"
  while true; do
    case "$1" in
      --debug )                   set_log_level $L_7DEBUG; shift ;;
      -v | --verbose )            set_log_level $L_6INFO; shift ;;
      --version )                 echo $VERSION; exit 0;;
      -h | --help )               usage; exit 0;;
      --nixcfg-path )             SRC_NIXCFG_PATH=$2; shift 2 ;;
      --use-defaults )            ARG_USE_DEFAULTS=true; shift ;;
      --hostname )                ARG_HOSTNAME=$2; shift 2 ;;
      --drive-path )              add_drive_to_pool_by_path "$2"; shift 2 ;;
      --drive-serial )            add_drive_to_pool_by_serial "$2"; shift 2 ;;
      --wipe-drives )             ARG_WIPE_DRIVES=$2; shift 2 ;; # quick || slow || quick+slow
      --zfs-pool-name )           ARG_ZFS_POOL_NAME=$2; shift 2 ;;
      --fs-type )                 ARG_FS_TYPE=$2; shift 2 ;; # zfs || native+zfs ## unsupported: luks+zfs
      --zfs-reserved-size )       ARG_ZFS_RESERVED_SIZE=$2; shift 2 ;;
      --swap-size )               ARG_SWAP_SIZE=$2; shift 2 ;;
      --reboot )                  ARG_REBOOT_AFTER_INSTALL=true; shift ;;
      --poweroff )                ARG_POWEROFF_AFTER_INSTALL=true; shift ;;
      -- ) shift; break ;;
      * ) break ;;
    esac
  done

  if (( ${EUID:-$(id -u)} != 0 )); then
    .log $L_3ERROR "Must run as root"
    exit 1
  fi

  uefi_or_legacy
  check_network_connection

  select_hostname
  select_boot_drives
  question_wipe_drives_quick
  question_wipe_drives_slow
  question_zfs_pool_name
  question_zfs_native_encryption
  question_zfs_reserved_size
  # if [ ${#ZFS_POOL_DRIVES[@]} == 1 ]; then
  #   # NOTE: Swap only in Single Drive mode
  #   question_swap_size ##TODO: SINGLE SWAP ALSO currently doesn't work???
  # fi
  SWAP_SIZE=""

  show_all_chosen_settings
  if [ "$ARG_USE_DEFAULTS" = false ]; then
    .log $L_4WARNING "The following script intends to replace all of your selected drive(s) contents with a zfs-on-root NixOS installation."
    ask_question_yn "Ready? <y/N> "
    [[ ! $REPLY =~ ^[Yy]$ ]] && die "Aborted."
  fi
  warn_countdown 10 "Making Disk Altering Changes in:" "clear"

  drive_prep
  partition_drive
  zpool_create
  configure_and_mount_partitions
  copy_nixcfg
  new_hostname_from_template
  generate_boot_loader_nix "/mnt/ssync/nixcfg/hosts/${SELECTED_HOSTNAME}"
  generate_hardware_configuration_nix "/mnt/ssync/nixcfg/hosts/${SELECTED_HOSTNAME}"
  # Change 'freshInstall = false;' to 'freshInstall = true;'
  sed 's|freshInstall = false;|freshInstall = true;|g' -i "/mnt/ssync/nixcfg/hosts/${SELECTED_HOSTNAME}/default.nix"

  START=$(date +%s)

    # .log $L_5NOTICE "nix flake update"
    # nix flake update --commit-lock-file "/mnt/ssync/nixcfg"

  .log $L_5NOTICE "nixos-install --root /mnt --flake \"path:/mnt/ssync/nixcfg#${SELECTED_HOSTNAME}\""
  if [ "$ARG_USE_DEFAULTS" = false ]; then
    ask_question "Press key to start installing nixos ... " ; read -r
  fi

  # use impure because of the nmd error: https://github.com/NixOS/nixpkgs/issues/122774
  nixos-install --flake "path:/mnt/ssync/nixcfg#${SELECTED_HOSTNAME}" --root /mnt --no-channel-copy --no-root-passwd --impure || die "nixos-install failed"

  END=$(date +%s)
  DIFF=$((END - START))
  .log $L_5NOTICE "duration: $(formatTime $DIFF)"

  installation_complete
}

_main "${@}"
