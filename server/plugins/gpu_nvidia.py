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
            + "encoder.stats.averageFps"
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
                "utilization": info["utilization.gpu"],
                "memory": {
                    "max": info["memory.total"],
                    "current": info["memory.used"],
                    "available": info["memory.free"],
                },
                "power": {
                    "max": info["power.limit"],
                    "current": info["power.draw"],
                },
                "frequency": {
                    "current": info["clocks.current.sm"],
                    "max": info["clocks.max.sm"],
                },
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
