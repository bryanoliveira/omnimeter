import abc


class PluginInterface(metaclass=abc.ABCMeta):
    @abc.abstractmethod
    def get_id(self) -> str:
        """
        Returns unique plugin ID.
        """
        raise NotImplementedError

    @abc.abstractmethod
    def get_name(self) -> str:
        """
        Returns plugin display name.
        """
        raise NotImplementedError

    @abc.abstractmethod
    def get_description(self) -> str:
        """
        Returns plugin description.
        """
        raise NotImplementedError

    @abc.abstractmethod
    def get_dict(self) -> dict:
        """
        Returns plugin info as a dictionary.
        """
        raise NotImplementedError
