import random

from dataclasses import dataclass
from Options import Range, Toggle, PerGameCommonOptions, Choice

from .locations import location_packs, LocationInfo
from .items import item_packs, ItemInfo


class LevelStarAllowedLocations(Range):
    """
    The number of star locations per level that are permitted to have progression items.
    """

    range_start = 1
    range_end = 3

    default = 3


class LevelSelect(Choice):
    """
    Abstract option for any time you need to select a level
    """
    pass

    tuple_map = {
        info.id: (tag, num)
        for tag, pack in item_packs.items()
        for num, info in pack.unlock_items.items()
    }
    """
    Map of values to tag and number, used to get the actual item info
    """

    def unlock_item(self) -> ItemInfo:
        tag, num = self.tuple_map[self.value]
        return item_packs[tag].unlock_items[num]

    def clear_loc(self) -> LocationInfo:
        tag, num = self.tuple_map[self.value]
        return location_packs[tag].clear_locations[num]

# evil post-metaclass hacking
LevelSelect.name_lookup = {
    idnum: f"{tag.lower().replace(' ', '_')}_{num}"
    for idnum, (tag, num) in LevelSelect.tuple_map.items()
}

LevelSelect.options = {
    name: idnum
    for idnum, name in LevelSelect.name_lookup.items()
}


class StartingLevel(LevelSelect):
    """
    The level that the player starts with.
    """

    default = 1001


class GoalLevel(LevelSelect):
    """
    The level that the player must complete to goal.
    """

    default = 2008


class RaceStarAllowedLocations(Range):
    """
    The number of star locations per race that are permitted to have progression items.
    """

    range_start = 1
    range_end = 3

    default = 3


class TotalStars(Range):
    """
    The total number of Star items to be placed in the multiworld for this game.
    """

    range_start = 10
    range_end = 261

    default = 50


class GoalStars(Range):
    """
    The percentage of total Star items required to goal the game.
    """

    range_start = 10
    range_end = 100

    default = 50


class Beefsanity(Toggle):
    """
    Whether or not the steaks in each stage are locations.
    """


class GoalSteaks(Range):
    """
    The number of Steak items required to goal the game. Only active when beefsanity is on.
    """

    range_start = 10
    range_end = 378

    default = 100


class TrapChance(Range):
    """
    The chance, expressed as percentage, for filler items to become traps.
    """

    range_start = 0
    range_end = 100

    default = 10


@dataclass
class CowOptions(PerGameCommonOptions):
    level_star_allowed_locations: LevelStarAllowedLocations
    starting_level: StartingLevel
    goal_level: GoalLevel
    race_star_allowed_locations: RaceStarAllowedLocations
    total_stars: TotalStars
    goal_star_percentage: GoalStars
    beefsanity: Beefsanity
    goal_steaks: GoalSteaks
    trap_chance: TrapChance
