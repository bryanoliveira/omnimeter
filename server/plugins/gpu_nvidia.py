# required interface
from plugin_interface import PluginInterface

# plugin imports
import csv
import os


SAFE_NAMES = {
    "index": "index",
    "name": "name",
    "temperature.gpu": "temperature",
    "utilization.gpu [%]": "utilization",
    "utilization.memory [%]": "memory",
    "fan.speed [%]": "fan",
    "power.draw [W]": "power",
    "clocks.current.sm [MHz]": "frequency_sm",
    "clocks.current.memory [MHz]": "frequency_memory",
    "clocks.current.graphics [MHz]": "frequency_graphics",
    "pstate": "performance_state",
}


class GPUPlugin(PluginInterface):
    def __init__(self):
        # nvidia-smi --help-query-gpu
        self.cmd = (
            "nvidia-smi -i 0 --query-gpu=index,name,"
            + "temperature.gpu,"
            + "utilization.gpu,"
            + "utilization.memory,"
            + "fan.speed,"
            + "power.draw,"
            + "clocks.sm,"
            + "pstate,"
            + "clocks.mem,"
            + "clocks.gr"
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
            gpus_info[int(info["index"])] = info
        return gpus_info

    def get_gpu_data(self):
        ns = os.popen(self.cmd)
        rows = list(csv.reader(ns.readlines()))
        headers = rows[0]
        data = []
        for row in rows[1:]:
            data.append(
                {
                    SAFE_NAMES[key.strip()]: value.strip()
                    for key, value in zip(headers, row)
                }
            )
        return data
