from dataclasses import dataclass

from .constants import num_levels, num_races

@dataclass
class LocationInfo:
    id: int
    name: str

base_level_clear_id = 1000
base_level_star_id = 2000

level_clear_locations: dict[int, LocationInfo] = {}
level_star_locations_by_stars: dict[int, dict[int, LocationInfo]] = {
    1: {},
    2: {},
    3: {}
}

locations_by_level: dict[int, list[LocationInfo]] = {}

for level_num in range(1, num_levels + 1):
    clear = LocationInfo(id=base_level_clear_id + level_num, name=f"Level {level_num} Clear")
    level_clear_locations[level_num] = clear

    stars = [
        LocationInfo(id=base_level_star_id + level_num * 3 + star_num, name=f"Level {level_num} Clear ({star_num} Star{'' if star_num == 1 else 's'})")
        for star_num in range(1, 4)
    ]

    for idx, item in enumerate(stars):
        level_star_locations_by_stars[idx + 1][level_num] = stars[idx]

    locations_by_level[level_num] = [clear, *stars]

level_star_locations = [loc for locs in level_star_locations_by_stars.values() for loc in locs.values()]

base_race_clear_id = 5000
base_race_star_id = 6000

race_clear_locations: dict[int, LocationInfo] = {}
race_star_locations_by_stars: dict[int, dict[int, LocationInfo]] = {
    1: {},
    2: {},
    3: {}
}

locations_by_race: dict[int, list[LocationInfo]] = {}

for race_num in range(1, num_races + 1):
    clear = LocationInfo(id=base_race_clear_id + race_num, name=f"Race {race_num} Clear")
    race_clear_locations[race_num] = clear

    stars = [
        LocationInfo(id=base_race_star_id + race_num * 3 + star_num, name=f"Race {race_num} Clear ({star_num} Star{'' if star_num == 1 else 's'})")
        for star_num in range(1, 4)
    ]

    for idx, item in enumerate(stars):
        race_star_locations_by_stars[idx + 1][race_num] = stars[idx]

    locations_by_race[race_num] = [clear, *stars]

race_star_locations = [loc for locs in race_star_locations_by_stars.values() for loc in locs.values()]

steak_stride = 100

level_steak_amounts = [
    2,  3,  6,  4,  4,  3,  5, 10,  4,  3,
    4,  4,  3,  3,  2,  4,  5,  5,  2,  1,
    5,  7,  7,  4,  5,  7,  3, 10,  5,  9,
    7,  9,  5,  3,  6,  3,  3,  4,  5,  4,
    3,  6,  7,  4,  5,  6,  3,  5,  4,  3,
    4,  4,  4,  3,  5,  3,  3,  3,  2,  3,
    3,  3,  5,  4,  6,  4,  6,  3,  4,  3,
    3,  6,  4,  3,  4,  2,  3,  4,  4
]

race_steak_amounts = [ 4, 5, 4, 5, 4, 7, 4, 3 ]

base_level_steak_id = 100000
base_race_steak_id = 200000

level_steak_locations_by_level: dict[int, list[LocationInfo]] = {}
race_steak_locations_by_level: dict[int, list[LocationInfo]] = {}

for level_num, steak_amount in enumerate(level_steak_amounts, 1):
    steaks = [
        LocationInfo(
            id=base_level_steak_id + steak_stride * level_num + steak_num,
            name=f"Level {level_num} Steak {steak_num}"
        )
        for steak_num in range(1, steak_amount + 1)
    ]

    level_steak_locations_by_level[level_num] = steaks
    locations_by_level[level_num].extend(steaks)

level_steak_locations = [
    loc
    for locs in level_steak_locations_by_level.values()
    for loc in locs
]

for race_num, steak_amount in enumerate(race_steak_amounts, 1):
    steaks = [
        LocationInfo(
            id=base_race_steak_id + steak_stride * race_num + steak_num,
            name=f"Race {race_num} Steak {steak_num}"
        )
        for steak_num in range(1, steak_amount + 1)
    ]

    race_steak_locations_by_level[race_num] = steaks
    locations_by_race[race_num].extend(steaks)

race_steak_locations = [
    loc
    for locs in race_steak_locations_by_level.values()
    for loc in locs
]

all_locations: list[LocationInfo] = [
    *level_clear_locations.values(),
    *level_star_locations,
    *race_clear_locations.values(),
    *race_star_locations,
    *level_steak_locations,
    *race_steak_locations,
]

locations_dict: dict[str, LocationInfo] = { loc.name: loc for loc in all_locations }
