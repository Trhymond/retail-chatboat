from abc import ABC, abstractmethod
from typing import Any


class ChatApproach(ABC):
    @abstractmethod
    async def run(self, history: list[dict], overrides: dict[str, Any]) -> Any:
        ...
