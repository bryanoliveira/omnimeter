import inspect
import logging
import pkgutil
from flask import Flask
from plugin_interface import PluginInterface


app = Flask(__name__)


plugins = []
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
