# eondota

A rapid-prototyping workspace. Between late 2022 and mid 2023 I was in the prototyping function for an unannounced PC game, during the gameplay loop exploration phase, working under contract - 1-2 playable prototypes per week, each built, playtested with a group, and either killed or folded into the next one.

This repository is where that happened. It is working code, not a showcase: the point was to answer design questions cheaply and move on, so most of it was written to survive a single playtest.

Built on Source 2 using the Dota 2 workshop tools, which gave us a mature engine, a working netcode layer, and an asset library — meaning a new mode could go from idea to a room full of people playing it in a couple of days rather than a couple of months. Lua throughout.

## How to read this repo

**Each branch is a prototype.** That's the whole structure. There's no build to run and no release to install — the branches are the artifact.

| Branch | What it tested |
|---|---|
| `initial-tests` | Earliest exploration map — movement, camera, core feel |
| `ctf` | Capture the flag |
| `archer` | Ranged-combat-focused mode |
| `aram-sphere` | Single-lane skirmish variant (alternate map w/ extra lanes) |
| `aram` | Single-lane skirmish variant |
| `essence_war` | Resource-capture warfare |
| `fire_essence` | Elemental-hazard map ("Firelands") |
| `building-mode` | Player construction |
| `building-mode-lane` | Construction constrained to lanes |
| `battle_royale` | Battle royale, shrinking play space |
| `royale_redux` | Battle royale, second pass |
| `duck_hunt` | Light-gun-style shooting |
| `galaga` | Fixed-shooter arcade experiment |
| `knockback_arena` | Displacement-as-win-condition brawler (mix of smash bros + warlocks) |
| `rts` | 5v5 real-time strategy |
| `rts_2v2` | RTS at reduced team size |
| `eon_tag` | Tag / pursuit |
| `eon_reverse_tag` | Tag with inverted roles |
| `ground_paint` | Territory control by surface painting |
| `dodgeball` | DODGEBALL! |
| `boss_fight` | Cooperative PvE encounter |
| `main` | Shared base and utilities |

## Caveats worth stating

**The branch count undercounts the prototypes.** Several branches went through two or three distinct designs before being abandoned, and some prototypes were merged into others rather than kept separate. Twenty-three branches, north of thirty actual prototypes.

**Code quality is deliberately uneven.** A prototype that exists to answer one question in three days should not be architected. Some of these are held together with globals and hardcoded values, and that was the correct call at the time. `main` is the only branch where shared code got any real care.

**Commit dates cluster.** Work was often pushed in batches, so a branch's last-commit date marks roughly when it was set down, not how long it took.

## Why this is public

Mostly so I can point at it. The interesting thing here isn't any individual prototype - it's the cadence, and the willingness to throw away twenty ideas to find the one worth building. That's hard to describe on a résumé and easy to see in a branch list.

Everything in here is exploratory work that never shipped. The game it fed into is a separate codebase.
