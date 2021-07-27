import inspect
import logging
import os
import pkgutil
import threading

from flask import Flask
import PySimpleGUIQt as sg

from plugin_interface import PluginInterface


app = Flask(__name__)
plugins = []


@app.route("/")
def get_stats():
    """
    Gets stats dicts from all modules in plugins folder
    """
    stats = {}
    for plugin in plugins:
        stats = {
            **stats,
            plugin.get_id(): plugin.get_dict(),
        }
    return stats


@app.route("/plugins")
def get_plugins():
    """
    Gets available plugin information
    """
    return {
        plugin.get_id(): {
            "name": plugin.get_name(),
            "description": plugin.get_description(),
        }
        for plugin in plugins
    }


def system_tray():
    tray = sg.SystemTray(
        menu=["BLANK", ["E&xit"]], filename="icon.svg", tooltip="OmniMeter"
    )
    while True:
        menu_item = tray.Read()
        if menu_item == "Exit":
            os._exit(0)


if __name__ == "__main__":
    try:
        for loader, modname, _ in pkgutil.walk_packages(path=["./plugins"]):
            print("Found module", modname)
            module = loader.find_module(modname).load_module(modname)
            print("Imported module", modname)
            for class_name, class_type in inspect.getmembers(module, inspect.isclass):
                print("Found class", class_name, class_type)
                if class_name != "PluginInterface" and issubclass(
                    class_type, PluginInterface
                ):
                    print("Found plugin", class_type)
                    plugins.append(class_type())
                    print("Installed plugin", class_type)
    except ImportError as e:
        print(e)
    except Exception as e:
        print(e)

    print("Plugins:", plugins)

    print("Starting system tray...")
    tray = threading.Thread(target=system_tray, args=())
    tray.start()

    print("Waking up device")
    os.popen("adb shell input keyevent KEYCODE_WAKEUP")

    print("Starting server...")
    app.run(
        host="0.0.0.0",
        port="5000",
        threaded=False,
        processes=1,
        # this are required to run a single instance
        use_reloader=False,
        use_debugger=False,
    )
