#!/usr/bin/env python3
"""Apply and audit location affinity for postcard copy.

The postcard library intentionally mixes generic category copy with landmark-
specific writing. Location-specific entries must carry an explicit whitelist
so a tram story cannot be rendered over the old-bookshop illustration.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
POSTCARDS_PATH = ROOT / "assets/data/postcard_templates.json"
LOCATIONS_PATH = ROOT / "assets/data/locations.json"


TEMPLATE_LOCATIONS: dict[str, list[str]] = {
    # Seaside
    "tpl_gl_hb_02": ["loc_tide_flat"],
    "tpl_lz_hb_03": ["loc_catback_reef"],
    "tpl_cu_hb_01": ["loc_lighthouse_bay"],
    "tpl_cu_hb_03": ["loc_tide_flat"],
    "tpl_ti_hb_03": ["loc_seafog_pier"],
    "tpl_en_hb_03": ["loc_lighthouse_bay"],
    "tpl_cl_hb_03": ["loc_shell_town"],
    "tpl_al_hb_03": ["loc_lighthouse_bay"],
    "tpl_na_hb_01": ["loc_seafog_pier"],
    "tpl_ge_hb_02": ["loc_shell_town"],
    "tpl_ge_hb_03": ["loc_tide_flat"],
    "tpl_dr_hb_02": ["loc_shell_town"],
    "tpl_dr_hb_03": ["loc_seafog_pier"],
    # Mountain
    "tpl_gl_sd_02": ["loc_snowline_cabin"],
    "tpl_lz_sd_01": ["loc_monkey_spring"],
    "tpl_lz_sd_03": ["loc_cloud_pass"],
    "tpl_cu_sd_01": ["loc_echo_canyon"],
    "tpl_cu_sd_03": ["loc_cloud_pass"],
    "tpl_ti_sd_01": ["loc_echo_canyon"],
    "tpl_ti_sd_02": ["loc_snowline_cabin"],
    "tpl_ti_sd_03": ["loc_monkey_spring"],
    "tpl_en_sd_03": ["loc_maple_ridge"],
    "tpl_cl_sd_03": ["loc_monkey_spring"],
    "tpl_al_sd_03": ["loc_snowline_cabin"],
    "tpl_na_sd_01": ["loc_echo_canyon"],
    "tpl_na_sd_03": ["loc_monkey_spring"],
    "tpl_ge_sd_02": ["loc_snowline_cabin"],
    "tpl_ge_sd_03": ["loc_monkey_spring"],
    "tpl_dr_sd_01": ["loc_cloud_pass"],
    "tpl_dr_sd_02": ["loc_echo_canyon"],
    "tpl_dr_sd_03": ["loc_maple_ridge"],
    # City
    "tpl_lz_cs_01": ["loc_rooftop_city"],
    "tpl_lz_cs_02": ["loc_tram_street"],
    "tpl_cu_cs_02": ["loc_tram_street"],
    "tpl_cu_cs_03": ["loc_oldbook_alley"],
    "tpl_ti_cs_01": ["loc_tram_street"],
    "tpl_en_cs_01": ["loc_tram_street"],
    "tpl_en_cs_02": ["loc_tram_street"],
    "tpl_en_cs_03": ["loc_rooftop_city"],
    "tpl_cl_cs_03": ["loc_ferris_wharf"],
    "tpl_al_cs_03": ["loc_oldbook_alley"],
    "tpl_na_cs_02": ["loc_oldbook_alley"],
    "tpl_na_cs_03": ["loc_rooftop_city"],
    "tpl_ge_cs_01": ["loc_midnight_noodles"],
    "tpl_ge_cs_03": ["loc_oldbook_alley"],
    "tpl_dr_cs_02": ["loc_ferris_wharf"],
    "tpl_dr_cs_03": ["loc_tram_street"],
    # Countryside
    "tpl_lz_xy_01": ["loc_wheat_post", "loc_apple_farm"],
    "tpl_lz_xy_03": ["loc_windmill_pond"],
    "tpl_cu_xy_01": ["loc_sunflower_station"],
    "tpl_cu_xy_02": ["loc_wheat_post"],
    "tpl_cu_xy_03": ["loc_firefly_paddy"],
    "tpl_ti_xy_02": ["loc_wheat_post"],
    "tpl_ti_xy_03": ["loc_wheat_post"],
    "tpl_en_xy_01": ["loc_wheat_post"],
    "tpl_en_xy_02": ["loc_windmill_pond"],
    "tpl_en_xy_03": ["loc_wheat_post"],
    "tpl_cl_xy_01": ["loc_wheat_post"],
    "tpl_cl_xy_03": ["loc_sunflower_station"],
    "tpl_al_xy_02": ["loc_wheat_post"],
    "tpl_al_xy_03": ["loc_firefly_paddy"],
    "tpl_na_xy_02": ["loc_wheat_post"],
    "tpl_na_xy_03": ["loc_windmill_pond"],
    "tpl_ge_xy_03": ["loc_sunflower_station"],
    "tpl_dr_xy_01": ["loc_firefly_paddy"],
    "tpl_dr_xy_02": ["loc_windmill_pond"],
    "tpl_dr_xy_03": ["loc_wheat_post"],
    # Forest
    "tpl_cu_sl_01": ["loc_mushroom_ring"],
    "tpl_cu_sl_02": ["loc_oak_postbox"],
    "tpl_cu_sl_03": ["loc_fog_bridge"],
    "tpl_ti_sl_03": ["loc_fog_bridge"],
    "tpl_en_sl_02": ["loc_oak_postbox"],
    "tpl_en_sl_03": ["loc_fog_bridge"],
    "tpl_cl_sl_01": ["loc_oak_postbox"],
    "tpl_cl_sl_03": ["loc_fog_bridge"],
    "tpl_al_sl_01": ["loc_fog_bridge"],
    "tpl_al_sl_03": ["loc_oak_postbox"],
    "tpl_na_sl_01": ["loc_pinecone_market"],
    "tpl_na_sl_02": ["loc_mushroom_ring"],
    "tpl_na_sl_03": ["loc_oak_postbox"],
    "tpl_ge_sl_03": ["loc_fog_bridge"],
    "tpl_dr_sl_01": ["loc_fog_bridge"],
    "tpl_dr_sl_02": ["loc_oak_postbox"],
    "tpl_dr_sl_03": ["loc_mushroom_ring"],
    # Desert
    "tpl_cu_sm_02": ["loc_salt_lake"],
    "tpl_cu_sm_03": ["loc_painted_bazaar"],
    "tpl_ti_sm_01": ["loc_camel_oasis"],
    "tpl_ti_sm_02": ["loc_painted_bazaar"],
    "tpl_ti_sm_03": ["loc_wind_rocks"],
    "tpl_en_sm_03": ["loc_balloon_camp"],
    "tpl_cl_sm_01": ["loc_salt_lake"],
    "tpl_cl_sm_02": ["loc_camel_oasis"],
    "tpl_al_sm_03": ["loc_balloon_camp"],
    "tpl_na_sm_01": ["loc_painted_bazaar"],
    "tpl_na_sm_02": ["loc_camel_oasis"],
    "tpl_na_sm_03": ["loc_balloon_camp"],
    "tpl_ge_sm_01": ["loc_camel_oasis"],
    "tpl_ge_sm_02": ["loc_painted_bazaar"],
    "tpl_dr_sm_01": ["loc_painted_bazaar"],
    "tpl_dr_sm_02": ["loc_salt_lake"],
    "tpl_dr_sm_03": ["loc_camel_oasis"],
    # Polar waters
    "tpl_gl_jd_01": ["loc_aurora_village", "loc_icefloe_lighthouse"],
    "tpl_gl_jd_02": ["loc_aurora_village", "loc_icefloe_lighthouse"],
    "tpl_gl_jd_03": ["loc_aurora_village"],
    "tpl_lz_jd_01": ["loc_aurora_village"],
    "tpl_lz_jd_02": ["loc_aurora_village", "loc_icefloe_lighthouse"],
    "tpl_lz_jd_03": ["loc_icefloe_lighthouse"],
    "tpl_cu_jd_01": ["loc_aurora_village"],
    "tpl_cu_jd_02": ["loc_aurora_village", "loc_icefloe_lighthouse"],
    "tpl_cu_jd_03": ["loc_blue_spring"],
    "tpl_ti_jd_01": ["loc_aurora_village", "loc_icefloe_lighthouse"],
    "tpl_ti_jd_02": ["loc_aurora_village"],
    "tpl_ti_jd_03": ["loc_steamboat_pier"],
    "tpl_en_jd_01": ["loc_aurora_village", "loc_icefloe_lighthouse"],
    "tpl_en_jd_03": ["loc_canal_town"],
    "tpl_cl_jd_01": ["loc_aurora_village"],
    "tpl_cl_jd_02": ["loc_aurora_village"],
    "tpl_cl_jd_03": ["loc_icefloe_lighthouse"],
    "tpl_al_jd_01": ["loc_aurora_village"],
    "tpl_al_jd_03": ["loc_aurora_village"],
    "tpl_na_jd_01": ["loc_aurora_village"],
    "tpl_na_jd_02": ["loc_aurora_village", "loc_icefloe_lighthouse"],
    "tpl_na_jd_03": ["loc_blue_spring"],
    "tpl_ge_jd_01": ["loc_aurora_village"],
    "tpl_ge_jd_03": ["loc_icefloe_lighthouse"],
    "tpl_dr_jd_01": ["loc_aurora_village"],
    "tpl_dr_jd_02": ["loc_blue_spring"],
    "tpl_dr_jd_03": ["loc_icefloe_lighthouse"],
    # Fantasy
    "tpl_gl_qh_01": ["loc_frosting_volcano"],
    "tpl_lz_qh_01": ["loc_cloud_ranch"],
    "tpl_lz_qh_03": ["loc_walking_island"],
    "tpl_cu_qh_01": ["loc_moon_post"],
    "tpl_cu_qh_02": ["loc_walking_island"],
    "tpl_cu_qh_03": ["loc_cloud_ranch"],
    "tpl_ti_qh_01": ["loc_walking_island"],
    "tpl_ti_qh_02": ["loc_moon_post"],
    "tpl_ti_qh_03": ["loc_frosting_volcano"],
    "tpl_en_qh_01": ["loc_cloud_ranch"],
    "tpl_en_qh_02": ["loc_walking_island"],
    "tpl_en_qh_03": ["loc_moon_post"],
    "tpl_cl_qh_01": ["loc_moon_post"],
    "tpl_cl_qh_02": ["loc_cloud_ranch"],
    "tpl_cl_qh_03": ["loc_walking_island"],
    "tpl_al_qh_03": ["loc_moon_post"],
    "tpl_na_qh_01": ["loc_cloud_ranch"],
    "tpl_na_qh_02": ["loc_moon_post"],
    "tpl_na_qh_03": ["loc_frosting_volcano"],
    "tpl_ge_qh_01": ["loc_moon_post"],
    "tpl_ge_qh_02": ["loc_walking_island"],
    "tpl_ge_qh_03": ["loc_cloud_ranch"],
    "tpl_dr_qh_03": ["loc_moon_post"],
}


ENCOUNTER_LOCATIONS: dict[str, list[str]] = {
    "enc_hb_02": ["loc_lighthouse_bay"],
    "enc_hb_05": ["loc_shell_town"],
    "enc_hb_06": ["loc_shell_town"],
    "enc_hb_07": ["loc_seafog_pier"],
    "enc_sd_01": ["loc_monkey_spring"],
    "enc_sd_04": ["loc_maple_ridge"],
    "enc_sd_05": ["loc_cloud_pass"],
    "enc_sd_07": ["loc_snowline_cabin"],
    "enc_sd_08": ["loc_monkey_spring"],
    "enc_cs_01": ["loc_midnight_noodles"],
    "enc_cs_02": ["loc_tram_street"],
    "enc_cs_03": ["loc_oldbook_alley"],
    "enc_cs_04": ["loc_rooftop_city"],
    "enc_cs_05": ["loc_tram_street"],
    "enc_cs_06": ["loc_ferris_wharf"],
    "enc_cs_07": ["loc_midnight_noodles"],
    "enc_cs_08": ["loc_ferris_wharf"],
    "enc_xy_01": ["loc_apple_farm"],
    "enc_xy_02": ["loc_wheat_post"],
    "enc_xy_03": ["loc_windmill_pond"],
    "enc_xy_04": ["loc_wheat_post"],
    "enc_xy_05": ["loc_windmill_pond"],
    "enc_xy_06": ["loc_wheat_post", "loc_sunflower_station"],
    "enc_xy_07": ["loc_apple_farm"],
    "enc_xy_08": ["loc_firefly_paddy"],
    "enc_sl_01": ["loc_pinecone_market"],
    "enc_sl_02": ["loc_logger_lodge"],
    "enc_sl_03": ["loc_oak_postbox"],
    "enc_sl_04": ["loc_mushroom_ring"],
    "enc_sl_05": ["loc_logger_lodge", "loc_oak_postbox"],
    "enc_sl_06": ["loc_fog_bridge"],
    "enc_sl_07": ["loc_fog_bridge"],
    "enc_sl_08": ["loc_logger_lodge"],
    "enc_sm_01": ["loc_camel_oasis"],
    "enc_sm_02": ["loc_painted_bazaar"],
    "enc_sm_03": ["loc_painted_bazaar"],
    "enc_sm_05": ["loc_balloon_camp"],
    "enc_sm_06": ["loc_camel_oasis"],
    "enc_sm_07": ["loc_salt_lake"],
    "enc_jd_01": ["loc_aurora_village"],
    "enc_jd_04": ["loc_icefloe_lighthouse"],
    "enc_jd_06": ["loc_steamboat_pier"],
    "enc_jd_07": ["loc_aurora_village"],
    "enc_qh_01": ["loc_moon_post"],
    "enc_qh_02": ["loc_cloud_ranch"],
    "enc_qh_03": ["loc_walking_island"],
    "enc_qh_04": ["loc_frosting_volcano"],
    "enc_qh_05": ["loc_star_repair"],
    "enc_qh_06": ["loc_moon_post"],
}


INCIDENT_LOCATIONS: dict[str, list[str]] = {
    "inc_hb_03": ["loc_tide_flat"],
    "inc_hb_06": ["loc_lighthouse_bay"],
    "inc_sd_01": ["loc_cloud_pass"],
    "inc_sd_02": ["loc_monkey_spring"],
    "inc_sd_03": ["loc_echo_canyon"],
    "inc_sd_04": ["loc_maple_ridge"],
    "inc_sd_05": ["loc_maple_ridge"],
    "inc_sd_06": ["loc_snowline_cabin"],
    "inc_sd_07": ["loc_cloud_pass"],
    "inc_sd_08": ["loc_snowline_cabin"],
    "inc_cs_01": ["loc_tram_street"],
    "inc_cs_02": ["loc_midnight_noodles"],
    "inc_cs_03": ["loc_tram_street", "loc_midnight_noodles"],
    "inc_cs_04": ["loc_oldbook_alley"],
    "inc_cs_05": ["loc_ferris_wharf"],
    "inc_cs_06": ["loc_rooftop_city"],
    "inc_cs_07": ["loc_midnight_noodles"],
    "inc_cs_08": ["loc_oldbook_alley"],
    "inc_xy_01": ["loc_apple_farm"],
    "inc_xy_02": ["loc_firefly_paddy"],
    "inc_xy_03": ["loc_sunflower_station"],
    "inc_xy_04": ["loc_wheat_post"],
    "inc_xy_05": ["loc_windmill_pond"],
    "inc_xy_06": ["loc_wheat_post"],
    "inc_xy_07": ["loc_apple_farm"],
    "inc_xy_08": ["loc_wheat_post"],
    "inc_sl_01": ["loc_mushroom_ring"],
    "inc_sl_02": ["loc_pinecone_market"],
    "inc_sl_04": ["loc_fog_bridge"],
    "inc_sl_06": ["loc_oak_postbox"],
    "inc_sl_07": ["loc_pinecone_market"],
    "inc_sm_01": ["loc_salt_lake"],
    "inc_sm_02": ["loc_painted_bazaar"],
    "inc_sm_04": ["loc_camel_oasis"],
    "inc_sm_06": ["loc_painted_bazaar"],
    "inc_sm_07": ["loc_balloon_camp"],
    "inc_sm_08": ["loc_salt_lake"],
    "inc_jd_01": ["loc_aurora_village"],
    "inc_jd_03": ["loc_steamboat_pier"],
    "inc_jd_04": ["loc_icefloe_lighthouse"],
    "inc_jd_05": ["loc_icefloe_lighthouse"],
    "inc_jd_06": ["loc_aurora_village"],
    "inc_jd_07": ["loc_blue_spring"],
    "inc_qh_01": ["loc_cloud_ranch"],
    "inc_qh_02": ["loc_walking_island"],
    "inc_qh_03": ["loc_moon_post"],
    "inc_qh_04": ["loc_frosting_volcano"],
    "inc_qh_05": ["loc_star_repair"],
}


def _load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def _apply(
    items: list[dict],
    expected: dict[str, list[str]],
    *,
    write: bool,
    errors: list[str],
) -> None:
    items_by_id = {item["id"]: item for item in items}
    unknown = sorted(set(expected) - set(items_by_id))
    if unknown:
        errors.append(f"unknown content ids: {', '.join(unknown)}")

    for item in items:
        wanted = expected.get(item["id"], [])
        actual = item.get("locationIds", [])
        if actual != wanted:
            if write:
                if wanted:
                    item["locationIds"] = wanted
                else:
                    item.pop("locationIds", None)
            else:
                errors.append(
                    f"{item['id']}: locationIds={actual!r}, expected {wanted!r}"
                )


def _validate(postcards: dict, locations: dict, errors: list[str]) -> None:
    location_by_id = {item["id"]: item for item in locations["items"]}
    collections = (
        ("template", postcards["templates"]),
        ("encounter", postcards["encounters"]),
        ("incident", postcards["incidents"]),
    )
    for kind, items in collections:
        for item in items:
            for location_id in item.get("locationIds", []):
                location = location_by_id.get(location_id)
                if location is None:
                    errors.append(f"{item['id']}: unknown location {location_id}")
                    continue
                if kind == "template" and item["category"] != location["category"]:
                    errors.append(
                        f"{item['id']}: category does not match {location_id}"
                    )
                if (
                    kind == "encounter"
                    and item["poolId"] != location["encounterPoolId"]
                ):
                    errors.append(f"{item['id']}: pool does not match {location_id}")
                if kind == "incident" and item["vibe"] not in location["vibeTags"]:
                    errors.append(f"{item['id']}: vibe does not match {location_id}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--write",
        action="store_true",
        help="write the canonical locationIds into postcard_templates.json",
    )
    args = parser.parse_args()

    postcards = _load(POSTCARDS_PATH)
    locations = _load(LOCATIONS_PATH)
    errors: list[str] = []
    _apply(
        postcards["templates"],
        TEMPLATE_LOCATIONS,
        write=args.write,
        errors=errors,
    )
    _apply(
        postcards["encounters"],
        ENCOUNTER_LOCATIONS,
        write=args.write,
        errors=errors,
    )
    _apply(
        postcards["incidents"],
        INCIDENT_LOCATIONS,
        write=args.write,
        errors=errors,
    )

    if args.write:
        POSTCARDS_PATH.write_text(
            json.dumps(postcards, ensure_ascii=False, indent=1),
            encoding="utf-8",
        )
        errors.clear()

    _validate(postcards, locations, errors)
    if errors:
        print("\n".join(f"ERROR: {error}" for error in errors))
        return 1

    mode = "updated" if args.write else "verified"
    tagged = sum(
        1
        for key in ("templates", "encounters", "incidents")
        for item in postcards[key]
        if item.get("locationIds")
    )
    print(f"PASS: postcard location affinity {mode} ({tagged} tagged entries)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
