# required interface
from plugin_interface import PluginInterface

# plugin imports
import os
import cpuinfo
import psutil


### WINDOWS
if os.name == 'nt':
    import wmi
    import clr #package pythonnet, not clr

    handle = None

    clr.AddReference(os.path.abspath('./lib/windows/OpenHardwareMonitorLib.dll'))
    from OpenHardwareMonitor import Hardware

    handle = Hardware.Computer()
    handle.CPUEnabled = True
    # handle.MainboardEnabled = True
    # handle.RAMEnabled = True
    # handle.GPUEnabled = True
    # handle.HDDEnabled = True
    handle.Open()

    def fetch_stats():
        global handle
        for i in handle.Hardware:
            i.Update()
            for sensor in i.Sensors:
                print("sensors", (sensor.Index, sensor.Hardware.HardwareType, sensor.SensorType, sensor.Hardware.Name, sensor.Name, sensor.Value))
            for j in i.SubHardware:
                j.Update()
                for subsensor in j.Sensors:
                    print("subsensor", (subsensor.Index, subsensor.Hardware.HardwareType, subsensor.SensorType, subsensor.Hardware.Name, subsensor.Name, subsensor.Value))

    def get_cpu_temperature() -> float:
        global handle
        if handle is None: return
        for i in handle.Hardware:
            i.Update()
            for sensor in i.Sensors:
                if "CPU Package" in sensor.Name and sensor.SensorType == 2: # 2 = Temperature
                    return float(sensor.Value)
        return 0.0

### POSIX
else:
    def get_cpu_temperature() -> float:
        psutil.sensors_temperatures()["k10temp"][0].current

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
            "temperature": get_cpu_temperature(),
        }
