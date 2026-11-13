# RXPPetTarget

A small WoW Forever addon for pet classes that use [RestedXP Guides](https://www.curseforge.com/wow/addons/rxp-guides).

RestedXP keeps a macro called `RXPTargeting` up to date with `/targetexact` lines for the mobs and NPCs in your current guide step. RXPPetTarget mirrors that macro into a per-character macro called **`RXPTargetPet`** and appends:

- **Warlock:** `/petattack [harm,nodead]` and `/cast [harm,nodead] Bane of Agony`
- **Hunter:** `/petattack [harm,nodead]`

One press targets the guide mob, sends your pet in and (on warlocks) tags the mob with Bane of Agony. Other classes are ignored by default, but you can add them (see [Customizing](#customizing)).

## Install

1. Copy this folder to `<WoW>/_forever_/Interface/AddOns/RXPPetTarget/`.
2. Restart the game (new addons are not picked up by `/reload`).
3. Open `/macro`, go to the character-specific tab and drag **RXPTargetPet** to your action bar.

## How it works

- RestedXP itself is not modified.
- The addon listens for `UPDATE_MACROS` and also checks once a second (out of combat) whether `RXPTargeting` changed, then rewrites `RXPTargetPet` only if the content differs.
- Macro edits are blocked in combat; changes made during combat are applied when combat ends.
- Macros are capped at 255 characters. If the extra lines do not fit, the oldest target lines are dropped, the same way RestedXP trims its own macro.

## Customizing

Everything the addon appends is set in the `CLASS_LINES` table at the top of `RXPPetTarget.lua`:

```lua
local CLASS_LINES = {
    WARLOCK = "/petattack [harm,nodead]\n/cast [harm,nodead] Bane of Agony",
    HUNTER = "/petattack [harm,nodead]",
}
```

Each entry is the macro text added after the `/targetexact` lines. Separate lines with `\n`. The key is the English class token: `WARRIOR`, `PALADIN`, `HUNTER`, `ROGUE`, `PRIEST`, `SHAMAN`, `MAGE`, `WARLOCK`, `DRUID`.

After editing, `/reload` in game.

**Use another spell instead of Bane of Agony** – replace the spell name (it must match your spellbook exactly):

```lua
WARLOCK = "/petattack [harm,nodead]\n/cast [harm,nodead] Corruption",
```

**Remove the pet** – drop the `/petattack` line:

```lua
WARLOCK = "/cast [harm,nodead] Bane of Agony",
```

**Tag-only for a class without a pet** – add a line for that class with just a spell:

```lua
MAGE = "/cast [harm,nodead] Fire Blast",
PRIEST = "/cast [harm,nodead] Shadow Word: Pain",
ROGUE = "/cast [harm,nodead] Throw",
```

**Target only, nothing else** – use an empty string. You then get a per-character copy of the RestedXP macro:

```lua
DRUID = "",
```

Keep the extra text short: macros are capped at 255 characters, and every character you add removes room for target lines.

## Notes

- Every press casts Bane of Agony again; macros cannot check whether the debuff is already on the target.
- The pet macro is per character and needs a free character macro slot.
