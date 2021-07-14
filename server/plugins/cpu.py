import psutil
from plugin_interface import PluginInterface


class CPUPlugin(PluginInterface):
    def get_id(self):
        return "default_cpu"

    def get_name(self):
        return "CPU"

    def get_description(self):
        return "A simple CPU monitor."

    def get_dict(self):
        freq = psutil.cpu_freq()
        return {
            "frequency": {
                "current": freq.current,
                "max": freq.max,
                "min": freq.min,
            },
        }
