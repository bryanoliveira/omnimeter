# required interface
from plugin_interface import PluginInterface

# plugin imports
import os
import cpuinfo
import psutil


class CPUPlugin(PluginInterface):
    def get_id(self):
        return "default_cpu"

    def get_name(self):
        return "CPU"

    def get_description(self):
        return "A simple CPU monitor."

    def get_dict(self):
        freq = psutil.cpu_freq()
        mem = psutil.virtual_memory()
        return {
            "name": " ".join(cpuinfo.get_cpu_info()["brand_raw"].split(" ")[:4]),
            "utilization": psutil.cpu_percent(interval=None),
            "memory": {
                "max": mem.total / (1024 ** 2),
                "current": (mem.total - mem.available) / (1024 ** 2),
                "available": mem.available / (1024 ** 2),
            },
            "frequency": {
                "current": freq.current,
                "max": freq.max,
                "min": freq.min,
            },
            "temperature": psutil.sensors_temperatures()["k10temp"][0].current if os.name == "posix" else 0.0,
        }
