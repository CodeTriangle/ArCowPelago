from dataclasses import dataclass
from Options import Range, Toggle, PerGameCommonOptions


class LevelStarAllowedLocations(Range):
    """
    The number of star locations per level that are permitted to have progression items.
    """

    range_start = 1
    range_end = 3

    default = 3


class StartingLevel(Range):
    """
    The level that the player starts with.
    """

    range_start = 1
    range_end = 79

    default = 1


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
    race_star_allowed_locations: RaceStarAllowedLocations
    total_stars: TotalStars
    goal_star_percentage: GoalStars
    beefsanity: Beefsanity
    goal_steaks: GoalSteaks
    trap_chance: TrapChance
