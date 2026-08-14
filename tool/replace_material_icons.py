from pathlib import Path

ROOT = Path(r"C:\projects\flutter\app_dinix\lib")
IMPORT = "import 'package:app_dinix/app_config/const/app_consts.dart';"

REPLACEMENTS = {
    "Icons.email_rounded": "Phosphor.envelope",
    "Icons.lock_rounded": "Phosphor.lock",
    "Icons.lock_outline_rounded": "Phosphor.lockSimple",
    "Icons.visibility_off_rounded": "Phosphor.eyeSlash",
    "Icons.visibility_rounded": "Phosphor.eye",
    "Icons.subscriptions_outlined": "Phosphor.stack",
    "Icons.subscriptions_rounded": "PhosphorFill.stack",
    "Icons.logout_rounded": "Phosphor.signOut",
    "Icons.chevron_right_rounded": "Phosphor.caretRight",
    "Icons.payments_outlined": "Phosphor.money",
    "Icons.payments_rounded": "Phosphor.money",
    "Icons.storefront_outlined": "Phosphor.storefront",
    "Icons.storefront_rounded": "Phosphor.storefront",
    "Icons.error_outline_rounded": "Phosphor.warningCircle",
    "Icons.dashboard_outlined": "Phosphor.squaresFour",
    "Icons.dashboard_rounded": "PhosphorFill.squaresFour",
    "Icons.receipt_long_outlined": "Phosphor.receipt",
    "Icons.receipt_long_rounded": "PhosphorFill.receipt",
    "Icons.account_balance_wallet_outlined": "Phosphor.wallet",
    "Icons.account_balance_wallet_rounded": "Phosphor.wallet",
    "Icons.person_outline_rounded": "Phosphor.user",
    "Icons.person_rounded": "PhosphorFill.user",
    "Icons.category_rounded": "Phosphor.tag",
    "Icons.keyboard_arrow_down_rounded": "Phosphor.caretDown",
    "Icons.wallet_rounded": "Phosphor.wallet",
    "Icons.event_rounded": "Phosphor.calendar",
    "Icons.calendar_today_rounded": "Phosphor.calendarBlank",
    "Icons.repeat_rounded": "Phosphor.arrowsClockwise",
    "Icons.description_outlined": "Phosphor.fileText",
    "Icons.notes_rounded": "Phosphor.note",
    "Icons.arrow_downward_rounded": "Phosphor.arrowDown",
    "Icons.check_circle_rounded": "Phosphor.checkCircle",
    "Icons.mark_email_read_outlined": "Phosphor.envelopeOpen",
    "Icons.arrow_back_rounded": "Phosphor.arrowLeft",
    "Icons.check_rounded": "Phosphor.check",
    "Icons.account_balance_rounded": "Phosphor.bank",
    "Icons.shopping_bag_rounded": "Phosphor.shoppingBag",
    "Icons.shopping_bag_outlined": "Phosphor.shoppingBag",
    "Icons.filter_1_rounded": "Phosphor.numberOne",
    "Icons.place_rounded": "Phosphor.mapPin",
    "Icons.location_city_rounded": "Phosphor.buildings",
    "Icons.map_rounded": "Phosphor.mapTrifold",
    "Icons.credit_card_rounded": "Phosphor.creditCard",
    "Icons.credit_card_outlined": "Phosphor.creditCard",
    "Icons.event_available_rounded": "Phosphor.calendarCheck",
    "Icons.add_rounded": "Phosphor.plus",
    "Icons.insights_outlined": "Phosphor.chartLine",
    "Icons.help_outline": "Phosphor.question",
    "Icons.inbox_outlined": "Phosphor.tray",
}

# Nav selected variants that should stay Fill even if the outlined mapping used regular wallet
NAV_FILL = {
    "lib/pages/home_shell.dart": {
        "iconSelected: Phosphor.wallet": "iconSelected: PhosphorFill.wallet",
        "iconSelected: Phosphor.user": "iconSelected: PhosphorFill.user",
        "iconSelected: Phosphor.stack": "iconSelected: PhosphorFill.stack",
        "iconSelected: Phosphor.receipt": "iconSelected: PhosphorFill.receipt",
        "iconSelected: Phosphor.squaresFour": "iconSelected: PhosphorFill.squaresFour",
    }
}


def needs_import(text: str) -> bool:
    return "Phosphor." in text or "PhosphorFill." in text


def ensure_import(text: str) -> str:
    if IMPORT in text:
        return text
    if "package:app_dinix/app_config/const/phosphor_icons.dart" in text:
        return text
    lines = text.splitlines(keepends=True)
    insert_at = 0
    for i, line in enumerate(lines):
        if line.startswith("import "):
            insert_at = i + 1
    phosphor_import = "import 'package:app_dinix/app_config/const/phosphor_icons.dart';\n"
    lines.insert(insert_at, phosphor_import)
    return "".join(lines)


def main() -> None:
    leftover = []
    for path in ROOT.rglob("*.dart"):
        original = path.read_text(encoding="utf-8")
        text = original
        for src, dst in sorted(REPLACEMENTS.items(), key=lambda x: -len(x[0])):
            text = text.replace(src, dst)
        rel = path.as_posix().replace("\\", "/")
        extras = NAV_FILL.get("lib/" + rel.split("/lib/")[-1] if "/lib/" in rel.replace("\\", "/") else None)
        # home_shell special
        if path.name == "home_shell.dart":
            text = text.replace("iconSelected: Phosphor.wallet", "iconSelected: PhosphorFill.wallet")
        if needs_import(text):
            text = ensure_import(text)
        if text != original:
            path.write_text(text, encoding="utf-8")
            print("updated", path.relative_to(ROOT.parent))
        if "Icons." in text and path.name != "phosphor_icons.dart":
            leftover.append(str(path.relative_to(ROOT.parent)))
    print("leftover Icons:", leftover)


if __name__ == "__main__":
    main()
