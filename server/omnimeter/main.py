import inspect
import logging
import os
import pkgutil

from flask import Flask
from flask_cors import CORS

from plugin_interface import PluginInterface

app = Flask(__name__)
CORS(app)
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


if __name__ == "__main__":
    try:
        for loader, modname, _ in pkgutil.walk_packages(path=["./plugins"]):
            logger.info("Found module", modname)
            module = loader.find_module(modname).load_module(modname)
            logger.info("Imported module", modname)
            for class_name, class_type in inspect.getmembers(module, inspect.isclass):
                logger.info("Found class", class_name, class_type)
                if class_name != "PluginInterface" and issubclass(
                    class_type, PluginInterface
                ):
                    logger.info("Found plugin", class_type)
                    plugins.append(class_type())
                    logger.info("Installed plugin", class_type)
    except ImportError as e:
        logger.error(e)
    except Exception as e:
        logger.error(e)

    logger.info("Plugins:", plugins)

    logger.info("Starting server...")
    app.run(
        host="0.0.0.0",
        port="5000",
        threaded=False,
        processes=1,
        # this are required to run a single instance
        use_reloader=False,
        use_debugger=False,
    )
