# required interface
from plugin_interface import PluginInterface

# plugin imports
import csv
import os


class GPUPlugin(PluginInterface):
    def __init__(self):
        # nvidia-smi --help-query-gpu
        self.cmd = (
            "nvidia-smi -i 0 --query-gpu=index,name,"
            + "temperature.gpu,"
            + "temperature.memory,"
            + "encoder.stats.averageFps,"
            + "utilization.gpu,"
            + "utilization.memory,"
            + "memory.total,"
            + "memory.used,"
            + "memory.free,"
            + "fan.speed,"
            + "power.draw,"
            + "power.limit,"
            + "clocks.current.sm,"
            + "clocks.max.sm,"
            + "clocks.current.graphics,"
            + "clocks.max.graphics,"
            + "clocks.current.memory,"
            + "clocks.max.memory,"
            + "pstate,"
            + " --format=csv,nounits -l1"
        )
        print("GPU command:", self.cmd)

    def get_id(self):
        return "default_nvidia_gpu"

    def get_name(self):
        return "NVIDIA GPU"

    def get_description(self):
        return "A simple NVIDIA GPU monitor"

    def get_dict(self):
        data = self.get_gpu_data()
        gpus_info = {}
        for info in data:
            gpus_info[int(info["index"])] = {
                "name": info["name"],
                "utilization": float(info["utilization.gpu"]),
                "temperature": float(info["temperature.gpu"]),
                "memory": {
                    "max": float(info["memory.total"]),
                    "current": float(info["memory.used"]),
                    "available": float(info["memory.free"]),
                },
                "power": {
                    "max": float(info["power.limit"]),
                    "current": float(info["power.draw"]),
                },
                "frequency": {
                    "current": float(info["clocks.current.sm"]),
                    "max": float(info["clocks.max.sm"]),
                },
                "fps": int(info["encoder.stats.averageFps"]),
            }
        return gpus_info

    def get_gpu_data(self):
        ns = os.popen(self.cmd)
        rows = list(csv.reader(ns.readlines()))
        headers = rows[0]
        data = []
        for row in rows[1:]:
            data.append(
                {
                    key.strip().split(" ")[0]: value.strip()
                    for key, value in zip(headers, row)
                }
            )
        return data
