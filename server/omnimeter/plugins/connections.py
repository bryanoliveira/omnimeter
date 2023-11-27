# required interface
from plugin_interface import PluginInterface

# plugin imports
import re
import subprocess


def count_ssh_users():
    try:
        # Execute the 'w' command
        output = subprocess.check_output("w", shell=True).decode()

        # Regular expression pattern to match IP addresses
        ip_pattern = re.compile(r"\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b")

        # Set to store unique user names
        unique_users = set()

        # Count SSH connections by detecting IP addresses
        ssh_count = 0
        for line in output.splitlines()[2:]:  # Skip the header lines
            columns = line.split()
            if len(columns) > 2 and ip_pattern.search(columns[2]):
                ssh_count += 1
                unique_users.add(columns[0])

        return ssh_count, len(unique_users)

    except subprocess.CalledProcessError as e:
        print(f"Error executing 'w' command: {e}")
        return 0
    except Exception as e:
        print(f"General error: {e}")
        return 0


class ConnectionsPlugin(PluginInterface):
    def get_id(self):
        return "default_connections"

    def get_name(self):
        return "Connections"

    def get_description(self):
        return "A simple SSH connections monitor."

    def get_dict(self):
        ssh_count, unique_users = count_ssh_users()
        return {"total": ssh_count, "users": unique_users}
