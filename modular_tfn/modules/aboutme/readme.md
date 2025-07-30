

## <Title AboutMe>
Module ID: ABOUT_ME_CORE
[https://github.com/NovaSector/NovaSector/pull/661]
### Description:
Hi! Thanks for your interest in this module. I’ll say outright I’m not an experienced programmer or contributor to BYOND projects—but I do have a love for UI. There are likely many oversights or places where things could be done differently on the backend, but I’ve done my best to make the system easy to understand, modify, build on, and adapt.

**Player Entry Point:**  
Human mobs get the `about_me` component (`aboutme_core.dm`) during `ComponentInitialize()`. This attaches a TGUI-access button that opens their "About Me" panel, displaying a central character identity page. It also sets up their group memberships based on role and species.

**Persistence is not implemented yet**, but this system is built to prepare for it.

**Round Start:**  
The `ssrpmanagement.dm` subsystem manages all About Me records and global data. It initializes canonical groups, stores them, and relationships, chronicles, and memories. All information is stored using dynamic access keys, and wiped round-to-round until persistence is ready.

**Files Overview:**
- `aboutme_defines.dm`: Central definitions (types, tags, group keys). To be split later.
- `aboutme_core.dm`: The player’s character data controller. Handles component behavior and display access.
- `aboutme_tgui.dm`: UI logic and act routing.
- `AboutmeInt.jsx`: Single About Me TGUI panel (5-tab layout), receives and displays player-specific payload.
- `aboutme_record.dm`: Stores the character’s aboutme_key, group affiliations, memories, and relationships.
- `ssrpmanagement.dm`: Subsystem manager for canonical groups and global RP state.
- `group.dm`, `relationships.dm`, `memory.dm`, `chronicle.dm`: Datums for their respective features.
- `groups_canon.dm`: Canonical group registration (Camarilla, Anarchs, etc).

**External Changes:**
(Not in the modular aboutme folder, but essential to the system.)
- Added `AboutmeInt.jsx`, for the player interface.
- TGUI bridge handled in `aboutme_tgui.dm`, connects JSX to backend act handlers.
- `AddComponent(/datum/component/about_me)` inserted in:
  - `/mob/living/carbon/human/ComponentInitialize()`

**Modular:**
Added `modular_tfn/modules/aboutme/` folder containing all components, records, datums, defines, and the RP subsystem.

**About Me Display Tabs:**
1. **Overview** – Name, role, species, stats, disciplines, regnant, etc.
2. **Groups** – Clans, sects, factions, tribes, organizations, coteries.
3. **Relationships** – Tracked relationships between players or groups.
4. **Chronicles** – Shared/group/memory-linked events (wars, deals, betrayals).
5. **Memories** – Player-authored log entries, secrets, goals, tags, and RP effects.

### TG Proc/File Changes:
- `code/modules/mob/living/carbon/human.dm`:  
  - `proc/ComponentInitialize()`  
    ```dm
    // NOVA EDIT ADDITION START - ABOUT_ME_CORE
    AddComponent(/datum/component/about_me)
    // NOVA EDIT ADDITION END
    ```

### Modular Overrides:
- N/A

### Defines:
- `aboutme_defines.dm`

### Included files that are not contained in this module:
- `AboutmeInt.jsx` in tgui/interfaces

### Credits:
MichaelEUkari - <3 - Let's make some memories.  
Soreyew - Prompted the faction system and favor tracking inspiration. (Favor tracking coming with persistence!)
