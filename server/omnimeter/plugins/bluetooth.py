# required interface
from plugin_interface import PluginInterface

# plugin imports
import os
import cpuinfo
import psutil


### WINDOWS
if os.name == "nt":
    def get_connected_bluetooth_devices_info():
        return []

### POSIX
else:

    def get_connected_bluetooth_devices_info():
        devices_info = []

        info_key_map = {
            "Name": "name",
            "Alias": "alias",
            "Icon": "icon",
        }

        devices = os.popen("bluetoothctl devices").readlines()
        for device in devices:
            mac = device.split(" ")[1]
            info_lines = os.popen(f"bluetoothctl info {mac}").readlines()
            info = {}
            for i, line in enumerate(info_lines):
                if i == 0: continue
                line = line.strip()
                key, value = line.split(": ", 1)
                info[key] = value

            if info["Connected"] == "yes":
                filtered_info = {}
                for key, value in info.items():
                    if key in info_key_map:
                        filtered_info[info_key_map[key]] = value

                # get battery
                regex = "[0-9]{1,3}%"
                cmd = f"""upower --dump | tr '[:lower:]' '[:upper:]' | awk "/{mac}/" RS= | grep -oE '{regex}'"""
                battery_info = os.popen(cmd).readlines()
                if len(battery_info) > 0:
                    filtered_info["battery"] = battery_info[0].strip()

                devices_info.append(filtered_info)

        return devices_info


class BluetoothPlugin(PluginInterface):
    def get_id(self):
        return "bluetooth"

    def get_name(self):
        return "BLUETOOTH"

    def get_description(self):
        return "A simple bluetooth info monitor."

    def get_dict(self):
        return {
            "devices": get_connected_bluetooth_devices_info()
        }