from rule_builder.rules import Has
from Options import OptionError
import settings
import typing
from .options import CowOptions
from .constants import num_levels, num_races
from .items import all_items, level_unlock_items, race_unlock_items, level_items, progression_items, filler_items, \
    trap_items, item_dict, star_item, steak_item, ItemInfo
from .locations import all_locations, level_clear_locations, level_star_locations_by_stars, level_star_locations, \
    race_clear_locations, race_star_locations_by_stars, race_star_locations, level_steak_locations_by_level, \
    level_steak_locations, race_steak_locations_by_level, race_steak_locations, locations_by_level, locations_by_race, \
    LocationInfo, level_steak_amounts, race_steak_amounts
from worlds.AutoWorld import World
from BaseClasses import Region, Location, Entrance, Item, ItemClassification


class CowItem(Item):
    game = "Cow"
    info: ItemInfo

    def __init__(self, player: int, info: ItemInfo):
        super().__init__(
            name=info.name,
            code=info.id,
            classification=info.classification,
            player=player
        )
        self.info = info


class CowLocation(Location):
    game = "Cow"
    info: LocationInfo

    def __init__(self, player: int, info: LocationInfo, region: Region | None = None):
        super().__init__(
            name=info.name,
            address=info.id,
            player=player,
            parent=region,
        )
        self.info = info


class CowWorld(World):
    """Insert description of the world/game here."""
    game = "Cow"  # name of the game/world
    options_dataclass = CowOptions  # options the player can set
    options: CowOptions  # typing hints for option results
    topology_present = True  # show path to required location checks in spoiler

    # The following two dicts are required for the generation to know which items exist.
    # They can be generated with arbitrary code during world load, but keep in mind that
    # anything expensive (e.g. parsing non-python data files) will delay world loading.
    # They can include events, but don't have to since events will be placed manually.
    item_name_to_id = {item.name: item.id for item in all_items}
    location_name_to_id = {location.name: location.id for location in all_locations}

    item_name_groups = {
        "Level Unlocks": [ item.name for item in level_unlock_items.values() ],
        "Race Unlocks": [ item.name for item in race_unlock_items.values() ],
        "Progression": [ item.name for item in progression_items ],
        "Filler": [ item.name for item in filler_items ],
        "Trap": [ item.name for item in trap_items ],
    }

    location_name_groups = {
        "Level Clears": [ loc.name for loc in level_clear_locations.values() ],
        "Level Star Clears": [ loc.name for loc in level_star_locations ],
        "Race Clears": [ loc.name for loc in race_clear_locations.values() ],
        "Race Star Clears": [ loc.name for loc in race_star_locations ],
        "Level Steaks": [ loc.name for loc in level_steak_locations ],
        "Race Steaks": [ loc.name for loc in race_steak_locations ],
    } | {
        f"Level {level_num}": [ loc.name for loc in locations ] for level_num, locations in locations_by_level.items()
    } | {
        f"Level {race_num}": [ loc.name for loc in locations ] for race_num, locations in locations_by_race.items()
    }

    goal_stars_amount: int = 0

    def create_item(self, name: str) -> CowItem:
        return CowItem(self.player, item_dict[name])

    def create_filler_item(self) -> CowItem:
        value = self.random.randint(1, 100)
        info = filler_items[0] if self.options.trap_chance <= value else self.random.choice(trap_items)
        return CowItem(self.player, info)

    def generate_early(self):
        stars_per_level = self.options.level_star_allowed_locations.value
        stars_per_race = self.options.race_star_allowed_locations.value
        max_stars = num_levels * stars_per_level + num_races * stars_per_race

        if self.options.total_stars > max_stars:
            raise OptionError(
                f"With {stars_per_level} stars per level and {stars_per_race} stars per race, "
                f"the maximum amount of stars that can be placed is {max_stars}."
            )

    def create_regions(self):
        menu = Region(
            name=f"Menu",
            multiworld=self.multiworld,
            player=self.player,
        )
        self.multiworld.regions.append(menu)

        for level_num in range(1, num_levels + 1):
            region = Region(
                name=f"Level {level_num}",
                multiworld=self.multiworld,
                player=self.player,
            )

            self.multiworld.regions.append(region)

            if self.options.starting_level == level_num:
                menu.connect(region)
            else:
                self.create_entrance(menu, region, Has(f"Level {level_num} Unlock"))

            region.locations.append(CowLocation(self.player, level_clear_locations[level_num], region))

            for star_num in range(1, 4):
                loc = CowLocation(self.player, level_star_locations_by_stars[star_num][level_num], region)
                if star_num > self.options.level_star_allowed_locations.value:
                    loc.item_rule = lambda item: not item.classification & ItemClassification.progression

                region.locations.append(loc)

            if self.options.beefsanity.value:
                region.locations.extend(
                    CowLocation(self.player, info, region)
                    for info in level_steak_locations_by_level[level_num]
                )

        for race_num in range(1, num_races + 1):
            region = Region(
                name=f"Race {race_num}",
                multiworld=self.multiworld,
                player=self.player,
            )

            self.multiworld.regions.append(region)

            self.create_entrance(menu, region, Has(f"Race {race_num} Unlock"))

            region.locations.append(CowLocation(self.player, race_clear_locations[race_num], region))

            for star_num in range(1, 4):
                loc = CowLocation(self.player, race_star_locations_by_stars[star_num][race_num], region)
                if star_num > self.options.race_star_allowed_locations.value:
                    loc.item_rule = lambda item: not item.classification & ItemClassification.progression

                region.locations.append(loc)

            if self.options.beefsanity.value:
                region.locations.extend(
                    CowLocation(self.player, info, region)
                    for info in race_steak_locations_by_level[race_num]
                )

        self.goal_stars_amount = self.options.total_stars.value * self.options.goal_star_percentage / 100

        if self.options.beefsanity:
            menu.add_event(
                "Victory",
                "Victory",
                lambda state: state.has("Star", self.player, self.goal_stars_amount) and state.has("Steak", self.player, self.options.goal_steaks.value)
            )
        else:
            menu.add_event(
                "Victory",
                "Victory",
                lambda state: state.has("Star", self.player, self.goal_stars_amount)
            )

    def create_items(self):
        itempool = []

        starting_level_unlock = CowItem(self.player, level_unlock_items[self.options.starting_level.value])
        self.multiworld.push_precollected(starting_level_unlock)

        itempool.extend(
            CowItem(self.player, info)
            for info in level_items
            if info.id != starting_level_unlock.info.id
        )

        itempool.extend(
            CowItem(self.player, star_item)
            for _ in range(self.options.total_stars)
        )

        if self.options.beefsanity.value:
            itempool.extend(
                CowItem(self.player, steak_item)
                for _ in range(sum(race_steak_amounts) + sum(level_steak_amounts))
            )

        num_filler_items = len(self.multiworld.regions.location_cache[self.player]) - len(itempool) - 1

        itempool.extend(
            self.create_filler_item()
            for _ in range(num_filler_items)
        )

        self.multiworld.itempool.extend(itempool)

    def fill_slot_data(self) -> dict[str, typing.Any]:
        return {
            "total_stars": self.options.total_stars.value,
            "goal_stars": self.goal_stars_amount,
            "beefsanity": bool(self.options.beefsanity.value),
            "goal_steaks": self.options.goal_steaks.value,
        }
