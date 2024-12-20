# required interface
from plugin_interface import PluginInterface

# plugin imports
import os
import subprocess


def is_display_on():
    if 'DISPLAY' not in os.environ:
        # No display available
        return False

    try:
        display = os.environ.get('DISPLAY', ':0')
        output = subprocess.check_output(f"DISPLAY={display} xset -q", shell=True, stderr=subprocess.STDOUT).decode()
        # Look for lines that indicate the display power status
        for line in output.split("\n"):
            if "Monitor is" in line:
                return "On" in line
        return False
    except Exception as e:
        print(f"Error: {e}")
        return False


class DisplayPlugin(PluginInterface):
    def get_id(self):
        return "default_display"

    def get_name(self):
        return "Display"

    def get_description(self):
        return "A simple Display monitor."

    def get_dict(self):
        return {
            "status": "on" if is_display_on() else "off",
        }
