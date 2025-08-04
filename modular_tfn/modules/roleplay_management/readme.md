## <Title AboutMe>
Module ID: ABOUT_ME_CORE  
[https://github.com/The-Final-Nights/The-Final-Nights/pull/661]

### Description

Hi! Thanks for your interest in this module. I’ll say outright I’m not an experienced programmer or contributor to BYOND projects—but I do have a love for UI and systems that make roleplay more fun I hope! There are probably places this could be more "BYONDy" or backend-efficient, but my goal was making the system easy to understand, modify, build on, and expand for future contributors, and myself!

### **Player Entry Point**

All human mobs get the `about_me` component (`aboutme_core.dm`) in `ComponentInitialize()`. This provides an "About Me" button in TGUI—your character’s central identity panel, accessible from the UI. The component also wires up the group/relationship/chronicle/memory systems and auto-registers basic group memberships (like faction, clan, or city) based on your character's role/species.

### **How It Works**

- **The SSRP Management Subsystem** (`ssroleplay_management.dm` and friends) handles:
  - Canonical group creation (city, factions, clans, orgs, etc) from `groups_canon.dm`
  - All About Me records, relationships, chronicles, and memories
  - Global lists for everything, keyed by character/group id
  - All data is currently *runtime only* (no persistence yet)
- **Component/Record System**: All in-character info is stored and referenced by `character_key`, never hardcoded to a mob.
- **Dynamic, Modular, and Easy to Build On**: All logic for tabbed UI, memory/chronicle/relationship management, and group/voting flows is in modular files, following the Nova modular structure.

### **File Overview and Responsibilities**

#### 1. **roleplay_management.dm**
- Centralizes all the systems defines, group/relationship/memory tags, types, group key macros, and helpers. Lots.
- Use these for type-safe role and group checks in your own procs!

#### 2. **aboutme_core.dm**
- Attaches the `about_me` component to the player.
- Controls character-key creation and About Me UI button.
- Provides main API for fetching and updating overview fields, groups, memories, etc.

#### 3. **aboutme_tgui.dm**
- Handles TGUI act routing and payload updates between the backend and AboutMeInt.jsx.
- All UI act() calls are dispatched here.

#### 4. **aboutme_record.dm**
- Stores all persistent player About Me data in a canonical record (not tied to mob!).
- Includes editable overview fields, group keys, relationships, chronicle and memory references.
- Responsible for building the UI payload sent to TGUI.

#### 5. **group.dm**
- **/datum/group**: The master group datum for all group types (city, clan, sect, org, party, etc).
- Tracks leaders, officers, members, display names, group orders, chronicles, active votes, and group relationships.
- Provides all core APIs for joining, leaving, promotion, demotion, voting, and invitations.
- Groups can be public or require approval.
- **/datum/group_vote**: Supports officer/leader promotion voting within a group, with vote result tracking and expiry.

#### 6. **relationships.dm**
- **/datum/relationships**: Represents a character↔character or character↔group relationship.
- Tracks type ("friend", "rival", "enemy", etc), description, tags, strength, visibility, and whether the relationship is mutual or group-based.
- API to format for UI and determine visibility.

#### 7. **chronicle.dm**
- **/datum/chronicle**: Represents a shared event, story arc, or major group moment.
- Tracks involved characters, groups, and related memories, with date, description, and tags.
- Used for both personal and group chronicles.
- API for UI formatting and (future) access control.

#### 8. **memory.dm**
- **/datum/memory**: Player-authored log entries, secrets, or event notes.
- Includes summary, details, tags (e.g. "background", "goal", "secret"), owner, related keys, date, and status.
- All player memories are registered and can be edited, tagged, or deleted from the UI.

#### 9. **groups_canon.dm**
- Registers all canonical (main) group datums at roundstart (city, factions, major clans, orgs, etc).
- Used by SSRP to enforce correct group/role mappings at runtime.

#### 10. **ssrpmanagement.dm**
- The core RP Management subsystem.
- Initializes all group and aboutme data, provides registration, lookup, and modification for every part of the About Me system.

#### 11. **AboutmeInt.jsx** (in tgui/interfaces)
- The actual TGUI interface. All data for your character's About Me is rendered here in 5 main tabs:
  1. Overview (character sheet)
  2. Groups (clan/sect/faction/org/party)
  3. Relationships (player-to-player and player-to-group)
  4. Chronicles (events and stories)
  5. Memories (your logs, secrets, and RP notes)

### **External Changes**
- Adds `AboutmeInt.jsx` for the new panel UI.
- Adds `AddComponent(/datum/component/about_me)` to `/mob/living/carbon/human/ComponentInitialize()`.

### **Key Concepts**

- **Tab-Based, Expandable UI:** Each About Me section (overview, groups, relationships, etc) is fully modular and easy to expand, if one breaks the rest should survive.
- **No Hard References:** All data is keyed and accessed by character's keys or group keys, allowing cross-round persistence (when implemented).
- **Voting & Group Management:** Groups support officer/leader voting, later dynamic votes, as well as loyalty-based leaving/restriction logic for certain types of groups.
- **Story-Driven:** Players and staff can log events, memories, and relationships in-game, supporting RP-focused narrative play.

### **Modular Layout**

All code lives in `modular_tfn/modules/aboutme/` (except for TGUI and roleplay_management.dm defines), following TFN’s modular standards for future-proofing.

### **Credits**

MichaelEUkari - <3 - Let's make some memories.  
Soreyew - Prompted the faction system and favor tracking inspiration. (Favor tracking coming with persistence!)

### **Contributing**

This is a living system! Please feel free to PR improvements, better persistence, new group types, or more user-friendly flows. UI/UX and story tool suggestions are always welcome!
