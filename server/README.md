Requires Python 3.7 because of pythonnet.
Select Python betwen 32 and 64-bit according to your system (it will not work otherwise - os.popen will fail).
On Windows it should run as admin to be able to read CPU temperature sensors (OpenHardwareMonitorLib).

Steps:

- Create a python env with requirements.txt (and requirements-windows.txt if running on Windows)
- `cd` into `omnimeter/` and run `python main.py` to check if it works
- Run `bash install.sh`
