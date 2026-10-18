from BaseClasses import ItemClassification
from dataclasses import dataclass

from .constants import num_levels, num_races

@dataclass
class ItemInfo:
    id: int
    name: str
    classification: ItemClassification = ItemClassification.progression

class ItemPack:
    """Stores data about a group of items with a shared tag"""

    # STATIC MEMBERS
    _rolling_base_unlock_id: int = 1000
    """(Static member) the base id of clear locations. Updated every time this class is instantiated."""

    # INSTANCE MEMBERS
    base_unlock_id: int
    """The base id of unlock items"""
    unlock_items: dict[int, ItemInfo]
    """Items that unlock levels, by the level they unlock"""

    def __init__(self, tag: str, amount: int):
        self.base_unlock_id = ItemPack._rolling_base_unlock_id
        ItemPack._rolling_base_unlock_id += 1000

        self.unlock_items = {
            num: ItemInfo(id=self.base_unlock_id + num, name=f"{tag} {num} Unlock")
            for num in range(1, amount + 1)
        }

item_packs: dict[str, ItemPack] = {
    'Level': ItemPack('Level', num_levels),
    'Race': ItemPack('Race', num_races),
}

base_race_unlock_id = 2000

level_items = [
    item
    for pack in item_packs.values()
    for item in pack.unlock_items.values()
]

steak_item = ItemInfo(id=10, name="Steak")
star_item = ItemInfo(id=11, name="Star")

misc_progression_items = [
    star_item,
    steak_item
]

progression_items = [
    *level_items,
    *misc_progression_items
]

filler_items = [
    ItemInfo(id=1, name="Moo", classification=ItemClassification.filler),
]

trap_items = [
    ItemInfo(id=60, name="Spike Ball Trap", classification=ItemClassification.trap),
    ItemInfo(id=61, name="Milk Trap", classification=ItemClassification.trap),
]

all_items = [
    *level_items,
    *progression_items,
    *filler_items,
    *trap_items,
]

item_dict = { item.name: item for item in all_items }
