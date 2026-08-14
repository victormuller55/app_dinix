import collections
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FONTS = ROOT / "assets" / "fonts" / "phosphor"
OUT = ROOT / "lib" / "app_config" / "const" / "phosphor_icons.dart"

RESERVED = {
    "class", "return", "switch", "case", "default", "if", "else", "for", "while",
    "in", "is", "as", "new", "true", "false", "null", "void", "var", "assert",
    "break", "continue", "do", "enum", "extends", "final", "finally", "import",
    "library", "operator", "part", "static", "super", "this", "throw", "try",
    "typedef", "with", "abstract", "const", "factory", "get", "implements",
    "interface", "mixin", "set", "late", "required", "sync", "async", "yield",
    "hide", "show", "on",
}


def to_camel(name: str) -> str:
    parts = [p for p in re.split(r"[^a-zA-Z0-9]+", name) if p]
    if not parts:
        return "icon"
    ident = parts[0].lower() + "".join(p[:1].upper() + p[1:] for p in parts[1:])
    if ident[0].isdigit():
        ident = "n" + ident
    if ident in RESERVED:
        ident = ident + "_"
    return ident


def load(path: Path, family_suffix: str = "") -> list[tuple[str, int]]:
    data = json.loads(path.read_text(encoding="utf-8"))
    items: list[tuple[str, int]] = []
    seen: collections.Counter[str] = collections.Counter()
    for icon in data["icons"]:
        raw = icon["properties"]["name"].split(",")[0].strip()
        if family_suffix and raw.endswith(family_suffix):
            raw = raw[: -len(family_suffix)].rstrip("-")
        code = icon["properties"]["code"]
        ident = to_camel(raw)
        seen[ident] += 1
        if seen[ident] > 1:
            ident = f"{ident}{seen[ident]}"
        items.append((ident, code))
    return items


def emit(class_name: str, family: str, items: list[tuple[str, int]]) -> str:
    lines = [
        f"class {class_name} {{",
        f"  {class_name}._();",
        f"  static const String family = '{family}';",
        "",
    ]
    for ident, code in items:
        lines.append(
            f"  static const IconData {ident} = IconData({code}, fontFamily: family);"
        )
    lines.append("}")
    return "\n".join(lines)


def main() -> None:
    regular = load(FONTS / "selection-regular.json")
    fill = load(FONTS / "selection-fill.json", family_suffix="-fill")
    header = (
        "// Gerado a partir de assets/fonts/phosphor (Phosphor Icons).\n"
        "// ignore_for_file: constant_identifier_names\n\n"
        "import 'package:flutter/widgets.dart';\n\n"
    )
    OUT.write_text(
        header
        + emit("Phosphor", "Phosphor", regular)
        + "\n\n"
        + emit("PhosphorFill", "PhosphorFill", fill)
        + "\n",
        encoding="utf-8",
    )
    print(f"wrote {OUT} ({len(OUT.read_text(encoding='utf-8').splitlines())} lines)")


if __name__ == "__main__":
    main()
