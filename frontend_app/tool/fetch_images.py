#!/usr/bin/env python3
"""
Fetch a photo for every attraction in attractions_seed.json.

Images come from Wikimedia Commons via the Wikipedia API — freely licensed and
safe to ship, unlike Google Images results. Each one is saved into
assets/images/, the JSON is patched to point at it, and IMAGE_CREDITS.md is
written so the report can attribute them properly.

Run from the project root:

    python3 tool/fetch_images.py

Standard library only — nothing to install.
"""

from __future__ import annotations

import json
import pathlib
import sys
import urllib.parse
import urllib.request

SEED = pathlib.Path("assets/data/attractions_seed.json")
IMAGE_DIR = pathlib.Path("assets/images")
CREDITS = pathlib.Path("IMAGE_CREDITS.md")

USER_AGENT = "RwandaGo-student-project/1.0 (educational use)"
THUMB_WIDTH = 900

# Candidate Wikipedia article titles per attraction id, tried in order.
# Places with no article of their own fall back to their town or district, so
# every card still gets something contextually right.
CANDIDATES: dict[str, list[str]] = {
    "volcanoes-np": ["Volcanoes National Park"],
    "lake-kivu": ["Lake Kivu"],
    "kigali-genocide-memorial": ["Kigali Genocide Memorial"],
    "nyungwe-forest": ["Nyungwe National Park", "Nyungwe Forest"],
    "kimironko-market": ["Kimironko", "Kigali"],
    "inema-arts-center": ["Kacyiru", "Kigali"],
    "akagera-np": ["Akagera National Park"],
    "kings-palace-nyanza": ["Nyanza, Rwanda", "Mwami of Rwanda"],
    "musanze-caves": ["Musanze", "Ruhengeri"],
    "ethnographic-museum": ["Huye", "Butare"],
    "heaven-restaurant": ["Nyarugenge", "Kigali"],
    "mount-bisoke": ["Mount Bisoke"],
}


def get_json(url: str) -> dict:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.loads(response.read().decode("utf-8"))


def find_image(title: str) -> tuple[str, str] | None:
    """Return (thumbnail_url, commons_file_title) for a Wikipedia article."""
    query = urllib.parse.urlencode(
        {
            "action": "query",
            "prop": "pageimages",
            "piprop": "thumbnail|name",
            "pithumbsize": THUMB_WIDTH,
            "titles": title,
            "redirects": 1,
            "format": "json",
        }
    )
    data = get_json(f"https://en.wikipedia.org/w/api.php?{query}")
    pages = data.get("query", {}).get("pages", {})
    for page in pages.values():
        thumb = page.get("thumbnail", {}).get("source")
        name = page.get("pageimage")
        if thumb and name:
            return thumb, name
    return None


def fetch_licence(file_name: str) -> tuple[str, str]:
    """Return (artist, licence) for a Commons file. Best effort."""
    query = urllib.parse.urlencode(
        {
            "action": "query",
            "prop": "imageinfo",
            "iiprop": "extmetadata",
            "titles": f"File:{file_name}",
            "format": "json",
        }
    )
    try:
        data = get_json(f"https://commons.wikimedia.org/w/api.php?{query}")
        pages = data.get("query", {}).get("pages", {})
        for page in pages.values():
            meta = page.get("imageinfo", [{}])[0].get("extmetadata", {})
            artist = meta.get("Artist", {}).get("value", "Unknown")
            licence = meta.get("LicenseShortName", {}).get("value", "See Commons")
            # extmetadata returns HTML; strip tags crudely for a plain credit.
            artist = _strip_html(artist)
            return artist, licence
    except Exception:
        pass
    return "Unknown", "See Wikimedia Commons"


def _strip_html(value: str) -> str:
    out, depth = [], 0
    for char in value:
        if char == "<":
            depth += 1
        elif char == ">":
            depth = max(0, depth - 1)
        elif depth == 0:
            out.append(char)
    return " ".join("".join(out).split())


def download(url: str, destination: pathlib.Path) -> None:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=60) as response:
        destination.write_bytes(response.read())


def main() -> int:
    if not SEED.exists():
        print(f"Cannot find {SEED}. Run this from the project root.")
        return 1

    IMAGE_DIR.mkdir(parents=True, exist_ok=True)
    attractions = json.loads(SEED.read_text(encoding="utf-8"))
    credits: list[str] = []
    found = 0

    for attraction in attractions:
        key = attraction["id"]
        titles = CANDIDATES.get(key, [attraction["name"]])
        result = None
        used_title = ""

        for title in titles:
            try:
                result = find_image(title)
            except Exception as error:
                print(f"  ! {title}: {error}")
                result = None
            if result:
                used_title = title
                break

        if not result:
            print(f"[skip] {attraction['name']} — no image found")
            continue

        thumb_url, file_name = result
        suffix = pathlib.Path(urllib.parse.urlparse(thumb_url).path).suffix or ".jpg"
        destination = IMAGE_DIR / f"{key}{suffix}"

        try:
            download(thumb_url, destination)
        except Exception as error:
            print(f"[fail] {attraction['name']} — {error}")
            continue

        attraction["imageUrl"] = destination.as_posix()
        artist, licence = fetch_licence(file_name)
        credits.append(
            f"- **{attraction['name']}** — {file_name}, via Wikimedia Commons "
            f"(article: {used_title}). Author: {artist}. Licence: {licence}."
        )
        found += 1
        print(f"[ok]   {attraction['name']} -> {destination}")

    SEED.write_text(json.dumps(attractions, indent=2, ensure_ascii=False) + "\n",
                    encoding="utf-8")

    CREDITS.write_text(
        "# Image credits\n\n"
        "All attraction photographs are sourced from Wikimedia Commons and "
        "reproduced under their respective free licences. Reproduce this list "
        "in the project report.\n\n" + "\n".join(credits) + "\n",
        encoding="utf-8",
    )

    print(f"\n{found} of {len(attractions)} images downloaded.")
    print("Add to pubspec.yaml under flutter: assets:  - assets/images/")
    return 0


if __name__ == "__main__":
    sys.exit(main())
