from dataclasses import dataclass

from .constants import num_levels, num_races, level_steak_amounts, race_steak_amounts

@dataclass
class LocationInfo:
    id: int
    name: str

class LocationPack:
    """Stores data about a group of levels with a shared tag"""

    # STATIC MEMBERS
    _rolling_base_clear_id: int = 1000
    """(Static member) the base id of clear locations. Updated every time this class is instantiated."""
    _rolling_base_steak_id: int = 100000
    """(Static member) the base id of steak locations. Updated every time this class is instantiated."""
    _steak_stride = 100
    """(Constant) the amount of locations to allocate for each level's steaks"""

    # INSTANCE MEMBERS
    base_clear_id: int
    """The base id of clear locations"""
    base_star_id: int
    """The base id of star locations"""
    clear_locations: dict[int, LocationInfo]
    """The locations acquired by clearing levels"""
    star_locations: list[LocationInfo]
    """All locations acquired by getting stars"""
    star_locations_by_stars: dict[int, dict[int, LocationInfo]]
    """Locations acquired by getting stars, indexed by number of stars"""
    locations_by_level: dict[int, list[LocationInfo]]
    """All clear and star locations by level number"""
    base_steak_id: int
    """The base id of steak locations"""
    steak_locations_by_level: dict[int, list[LocationInfo]]
    """The base id of steak locations"""
    steak_locations: list[LocationInfo]
    """All locations acquired by gathering steaks"""

    def __init__(self, tag: str, steak_amounts: list[int]):
        amount = len(steak_amounts)
        base_id = LocationPack._rolling_base_clear_id
        LocationPack._rolling_base_clear_id += 4000

        self.base_clear_id = base_id
        self.base_star_id = base_id + 1000

        self.clear_locations = {}
        self.star_locations_by_stars = {
            1: {},
            2: {},
            3: {}
        }

        self.locations_by_level = {}

        for num in range(1, amount + 1):
            clear = LocationInfo(id=self.base_clear_id + num, name=f"{tag} {num} Clear")
            self.clear_locations[num] = clear

            stars = [
                LocationInfo(id=self.base_star_id + num * 3 + star_num, name=f"{tag} {num} Clear ({star_num} Star{'' if star_num == 1 else 's'})")
                for star_num in range(1, 4)
            ]

            for idx, _ in enumerate(stars):
                self.star_locations_by_stars[idx + 1][num] = stars[idx]

            self.locations_by_level[num] = [clear, *stars]

        self.star_locations = [loc for locs in self.star_locations_by_stars.values() for loc in locs.values()]

        self.base_steak_id = LocationPack._rolling_base_steak_id
        LocationPack._rolling_base_steak_id += 100000

        self.steak_locations_by_level: dict[int, list[LocationInfo]] = {}

        for level_num, steak_amount in enumerate(steak_amounts, 1):
            steaks = [
                LocationInfo(
                    id=self.base_steak_id + LocationPack._steak_stride * level_num + steak_num,
                    name=f"{tag} {level_num} Steak {steak_num}"
                )
                for steak_num in range(1, steak_amount + 1)
            ]

            self.steak_locations_by_level[level_num] = steaks
            self.locations_by_level[level_num].extend(steaks)

        self.steak_locations = [
            loc
            for locs in self.steak_locations_by_level.values()
            for loc in locs
        ]

location_packs: dict[str, LocationPack] = {
    'Level': LocationPack('Level', level_steak_amounts),
    'Race': LocationPack('Race', race_steak_amounts),
}

all_locations: list[LocationInfo] = [
    loc 
    for pack in location_packs.values()
    for loc in (
        *pack.clear_locations.values(),
        *pack.star_locations,
        *pack.steak_locations
    )
]

locations_dict: dict[str, LocationInfo] = { loc.name: loc for loc in all_locations }
