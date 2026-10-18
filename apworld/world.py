from rule_builder.rules import Has
from Options import OptionError, Option
import settings
import typing
from .options import CowOptions, StartingLevel, LevelSelect
from .constants import num_levels, num_races
from .items import all_items, item_packs, level_items, progression_items, filler_items, \
    trap_items, item_dict, star_item, steak_item, ItemInfo
from .locations import all_locations, location_packs, LocationInfo
from worlds.AutoWorld import World, WebWorld
from BaseClasses import Region, Location, Entrance, Item, ItemClassification, Tutorial


class CowWeb(WebWorld):
    theme = "stone"

    setup_en = Tutorial(
        "Multiworld Setup Guide",
        "A guide to playing Cow with Archipelago",
        "English",
        "setup_en.md",
        "setup/en",
        ["CodeTriangle"]
    )
    tutorials = [setup_en]


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
    """The steaks have never been higher! Cow is the one and only fast-paced game about a cow riding a skateboard in
    a volcano above a pool of lava 🤘. Hop on your deck and milk each level, or become a well-done dinner.
    """
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
        "Progression": { item.name for item in progression_items },
        "Filler": { item.name for item in filler_items },
        "Trap": { item.name for item in trap_items },
    } | {
        f"{tag} Unlocks": { item.name for item in pack.unlock_items.values() }
        for tag, pack in item_packs.items()
    }

    # list comprehension from hell
    location_name_groups = {
        k: v
        for tag, pack in location_packs.items()
        for k, v in (
            (f"{tag} Clears", { loc.name for loc in pack.clear_locations.values() }),
            (f"{tag} Star Clears", { loc.name for loc in pack.star_locations }),
            (f"{tag} Steaks", { loc.name for loc in pack.steak_locations }),
            *(
                (f"{tag} {level_num}", { loc.name for loc in locations })
                for level_num, locations in pack.locations_by_level.items()
            )
        )
    }

    goal_stars_amount: int = 0

    allowed_locations_by_tag: dict[str, Option]

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

        self.allowed_locations_by_tag = {
            'Level': self.options.level_star_allowed_locations,
            'Race': self.options.race_star_allowed_locations,
        }

        if self.options.starting_level.value == self.options.goal_level.value:
            raise OptionError(f"Starting level cannot be equal to goal level")

    def create_regions(self):
        menu = Region(
            name=f"Menu",
            multiworld=self.multiworld,
            player=self.player,
        )
        self.multiworld.regions.append(menu)

        for tag, pack in location_packs.items():
            for level_num in pack.clear_locations:
                region = Region(
                    name=f"{tag} {level_num}",
                    multiworld=self.multiworld,
                    player=self.player,
                )

                self.multiworld.regions.append(region)

                self.create_entrance(menu, region, Has(f"{tag} {level_num} Unlock"))

                region.locations.append(CowLocation(self.player, pack.clear_locations[level_num], region))

                for star_num in range(1, 4):
                    loc = CowLocation(self.player, pack.star_locations_by_stars[star_num][level_num], region)
                    if star_num > self.allowed_locations_by_tag[tag].value:
                        loc.item_rule = lambda item: not item.classification & ItemClassification.progression

                    region.locations.append(loc)

                if self.options.beefsanity.value:
                    region.locations.extend(
                        CowLocation(self.player, info, region)
                        for info in pack.steak_locations_by_level[level_num]
                    )

        self.goal_stars_amount = self.options.total_stars.value * self.options.goal_star_percentage / 100

        if self.options.beefsanity:
            menu.add_event(
                "Victory",
                "Victory",
                lambda state: (
                    state.has("Star", self.player, self.goal_stars_amount) and
                    state.has("Steak", self.player, self.options.goal_steaks.value) and
                    state.can_reach_location(self.options.goal_level.clear_loc().name, self.player)
                )
            )
        else:
            menu.add_event(
                "Victory",
                "Victory",
                lambda state: (
                    state.has("Star", self.player, self.goal_stars_amount) and
                    state.can_reach_location(self.options.goal_level.clear_loc().name, self.player)
                )
            )

    def create_items(self):
        itempool = []

        starting_level_unlock = CowItem(self.player, self.options.starting_level.unlock_item())
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
                for _ in range(
                    sum(len(pack.steak_locations) for pack in location_packs.values())
                )
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
            "goal_level": list(LevelSelect.tuple_map[self.options.goal_level.value]),
        }
