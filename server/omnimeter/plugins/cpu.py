# required interface
from plugin_interface import PluginInterface

# plugin imports
import os
import cpuinfo
import psutil


### WINDOWS
if os.name == "nt":
    import clr  # package pythonnet, not clr

    handle = None
    stats = {
        "cpu_temp": 0.0,
        "cpu_clocks": [],
        "cpu_clock": 0.0,
    }

    clr.AddReference(os.path.abspath("./lib/windows/OpenHardwareMonitorLib.dll"))
    from OpenHardwareMonitor import Hardware

    handle = Hardware.Computer()
    handle.CPUEnabled = True
    # handle.MainboardEnabled = True
    # handle.RAMEnabled = True
    # handle.GPUEnabled = True
    # handle.HDDEnabled = True
    handle.Open()

    def fetch_stats():
        for i in handle.Hardware:
            i.Update()
            for sensor in i.Sensors:
                # print("sensors", (sensor.Index, sensor.Hardware.HardwareType, sensor.SensorType, sensor.Hardware.Name, sensor.Name, sensor.Value))
                if sensor.Hardware.HardwareType == 2:
                    if (
                        sensor.SensorType == 1 and "CPU Core" in sensor.Name
                    ):  # 1 = Clock
                        if len(stats["cpu_clocks"]) < sensor.Index:
                            stats["cpu_clocks"].append(float(sensor.Value))
                        else:
                            stats["cpu_clocks"][sensor.Index - 1] = float(sensor.Value)
                    elif (
                        sensor.SensorType == 2 and "CPU Package" in sensor.Name
                    ):  # 2 = Temperature
                        stats["cpu_temp"] = float(sensor.Value)
            for j in i.SubHardware:
                j.Update()
                for subsensor in j.Sensors:
                    print(
                        "subsensor",
                        (
                            subsensor.Index,
                            subsensor.Hardware.HardwareType,
                            subsensor.SensorType,
                            subsensor.Hardware.Name,
                            subsensor.Name,
                            subsensor.Value,
                        ),
                    )

        if len(stats["cpu_clocks"]) > 0:
            stats["cpu_clock"] = sum(stats["cpu_clocks"]) / len(stats["cpu_clocks"])

    def get_cpu_temperature() -> float:
        return stats["cpu_temp"]

    def get_cpu_clock() -> float:
        if stats["cpu_clock"] > 0:
            return (stats["cpu_clock"], 0, 5)
        else:
            freq = psutil.cpu_freq()
            return (freq.current, freq.min, freq.max)


### POSIX
else:

    def fetch_stats():
        pass

    def get_cpu_temperature() -> float:
        return psutil.sensors_temperatures()["k10temp"][0].current

    def get_cpu_clock() -> float:
        freq = psutil.cpu_freq()
        return (freq.current, freq.min, freq.max)


class CPUPlugin(PluginInterface):
    def get_id(self):
        return "default_cpu"

    def get_name(self):
        return "CPU"

    def get_description(self):
        return "A simple CPU monitor."

    def get_dict(self):
        fetch_stats()
        clock, clock_min, clock_max = get_cpu_clock()
        mem = psutil.virtual_memory()
        swap = psutil.swap_memory()

        return {
            "name": " ".join(cpuinfo.get_cpu_info()["brand_raw"].split(" ")[:4]),
            "utilization": psutil.cpu_percent(interval=None),
            "memory": {
                "max": mem.total / (1024 ** 2),
                "current": (mem.total - mem.available) / (1024 ** 2),
                "available": mem.available / (1024 ** 2),
            },
            "swap": {
                "max": swap.total / (1024 ** 2),
                "current": (swap.total - swap.free) / (1024 ** 2),
                "available": swap.free / (1024 ** 2),
            },
            "frequency": {"current": clock, "max": clock_max, "min": clock_min,},
            "temperature": get_cpu_temperature(),
            "core_usage": psutil.cpu_percent(interval=None, percpu=True),
        }
