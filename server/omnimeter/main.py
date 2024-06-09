import inspect
import logging
import os
import pkgutil

from flask import Flask, request
from flask_cors import CORS

from plugin_interface import PluginInterface

app = Flask(__name__)
CORS(app)
logging.basicConfig()
logger = logging.getLogger("werkzeug")
logger.setLevel(logging.ERROR)

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


@app.route("/desk_status", methods=["POST"])
def receive_desk_status():
    """
    Receives and updates the desk status for the plugin with id "standing_desk"
    """
    desk_status = request.json
    for plugin in plugins:
        if plugin.get_id() == "standing_desk":
            plugin.set_distance(desk_status.get("distance", plugin.distance))
            break
    return {}


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
        logger.error(e)
    except Exception as e:
        logger.error(e)

    print("Plugins:", plugins)

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
