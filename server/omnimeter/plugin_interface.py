import abc
import threading
import time


class PluginInterface(metaclass=abc.ABCMeta):
    def __init__(self):
        self._cache: dict | None = None
        self._cache_time: float = 0.0
        self._cache_ttl: float = 2.0
        self._updating = False
        self._lock = threading.Lock()

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
    def _fetch_data(self) -> dict:
        """
        Fetches and returns plugin data as a dictionary.
        Subclasses must implement this with their actual data collection logic.
        """
        raise NotImplementedError

    def get_dict(self) -> dict:
        """
        Returns plugin info as a dictionary, with caching.
        On first call, fetches synchronously. On subsequent calls, returns
        cached data and triggers an async refresh if the cache is stale.
        """
        if self._cache is None:
            self._cache = self._fetch_data()
            self._cache_time = time.monotonic()
            return self._cache

        if time.monotonic() - self._cache_time > self._cache_ttl:
            with self._lock:
                if not self._updating:
                    self._updating = True
                    thread = threading.Thread(
                        target=self._background_update, daemon=True
                    )
                    thread.start()

        return self._cache

    def _background_update(self):
        try:
            data = self._fetch_data()
            self._cache = data
            self._cache_time = time.monotonic()
        finally:
            with self._lock:
                self._updating = False

    def set_cache_ttl(self, ttl: float):
        self._cache_ttl = ttl
