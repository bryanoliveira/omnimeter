# required interface
from plugin_interface import PluginInterface

SITTING_STANDING_THRESHOLD = 850  # mm


class StandingDeskPlugin(PluginInterface):
    def __init__(self):
        self.distance = 0
        self.standing = False

    def get_id(self):
        return "standing_desk"

    def get_name(self):
        return "Standing Desk"

    def get_description(self):
        return "A simple sitting/standing desk monitor."

    def set_distance(self, distance):
        self.distance = distance
        self.standing = distance > SITTING_STANDING_THRESHOLD

    def get_dict(self):
        return {
            "distance": self.distance,
            "standing": self.standing,
        }
