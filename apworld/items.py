from BaseClasses import ItemClassification
from dataclasses import dataclass

from .constants import num_levels, num_races

@dataclass
class ItemInfo:
    id: int
    name: str
    classification: ItemClassification = ItemClassification.progression

base_level_unlock_id = 1000

level_unlock_items = {
    level_num: ItemInfo(id=base_level_unlock_id + level_num, name=f"Level {level_num} Unlock")
    for level_num in range(1, num_levels + 1)
}

base_race_unlock_id = 2000

race_unlock_items = {
    race_num: ItemInfo(id=base_race_unlock_id + race_num, name=f"Race {race_num} Unlock")
    for race_num in range(1, num_races + 1)
}

level_items = [
    *level_unlock_items.values(),
    *race_unlock_items.values(),
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
