// ====================
// AboutMeInt.jsx - Annotated
// ====================
// This file defines the main About Me interface for the player.
// Each major section/tab is separated and commented.

import React, { useState } from 'react';
import { useBackend, useLocalState } from '../backend';
import { Section, Tabs, Box, Button, Table, LabeledList } from 'tgui-core/components';
import { Window } from '../layouts';

const OverviewSection = ({ overview = {}, status, alignment, act }) => {
  const { general = {}, species = {} } = overview ?? {};
  const {
    name, role, special_role, species: speciesName, regnant, regnant_clan, stats = {},
    goals, personal_quote, gender, physical_desc,
  } = general;
  const {
    clan, generation, masquerade, morality_path, morality_score, disciplines = [],
  } = species;

  const displayOrUnknown = val =>
    val === undefined || val === null || val === "" ? "Unknown" : val;

  const isKnown = val =>
    val !== undefined && val !== null && val !== "";

  const [disciplinesOpen, setDisciplinesOpen] = useState(false);
  const [statsOpen, setStatsOpen] = useState(false);
  const [speciesOpen, setSpeciesOpen] = useState(false);

  return (
    <Section fill title="Overview">
      <Button icon="edit" content="Edit Overview" onClick={() => act('edit_overview')} mb={2} />

      {/* Character Details */}
      <Box mb={2}>
        <Box bold underline mb={1}>Character Details</Box>
        <LabeledList>
          {!!name && name !== "Unknown" && (
            <LabeledList.Item label="Name">{name}</LabeledList.Item>
          )}
          {!!speciesName && speciesName !== "Unknown" && (
            <LabeledList.Item label="Species">{speciesName}</LabeledList.Item>
          )}
          {!!role && role !== "Unknown" && (
            <LabeledList.Item label="Role">
              {role}{special_role && ` (${special_role})`}
            </LabeledList.Item>
          )}
          {!!goals && goals !== "Unknown" && (
            <LabeledList.Item label="Goals">{goals}</LabeledList.Item>
          )}
          {!!personal_quote && personal_quote !== "Unknown" && (
            <LabeledList.Item label="Personal Quote">{personal_quote}</LabeledList.Item>
          )}
          {!!gender && gender !== "Unknown" && (
            <LabeledList.Item label="Gender/Pronouns">{gender}</LabeledList.Item>
          )}
          {!!physical_desc && physical_desc !== "Unknown" && (
            <LabeledList.Item label="Physical Description">{physical_desc}</LabeledList.Item>
          )}
          {!!general.bank_account_code && general.bank_account_code !== "Unknown" && (
            <LabeledList.Item label="Bank Account Code">{general.bank_account_code}</LabeledList.Item>
          )}
          {!!general.armory_code && general.armory_code !== "Unknown" && (
            <LabeledList.Item label="Armory Code">{general.armory_code}</LabeledList.Item>
          )}
          {!!general.panic_room_code && general.panic_room_code !== "Unknown" && (
            <LabeledList.Item label="Panic Room Code">{general.panic_room_code}</LabeledList.Item>
          )}
          {!!general.bank_vault_code && general.bank_vault_code !== "Unknown" && (
            <LabeledList.Item label="Bank Vault Code">{general.bank_vault_code}</LabeledList.Item>
          )}
        </LabeledList>
      </Box>


      {/* Collapsible Attributes (Stats) */}
      {Object.keys(stats).length > 0 && (
        <Box mb={2}>
          <Box
            bold
            underline
            style={{ cursor: 'pointer', userSelect: 'none' }}
            onClick={() => setStatsOpen(o => !o)}
          >
            {statsOpen ? '▼' : '►'} Attributes
          </Box>
          {statsOpen && (
            <LabeledList>
              {Object.entries(stats).map(([k, v], i) => (
                <LabeledList.Item key={`stat-${i}`} label={k}>{v}</LabeledList.Item>
              ))}
            </LabeledList>
          )}
        </Box>
      )}

      {/* Collapsible Species Information */}
      {(clan || generation || masquerade || morality_path || morality_score) && (
        <Box mb={2}>
          <Box
            bold
            underline
            style={{ cursor: 'pointer', userSelect: 'none' }}
            onClick={() => setSpeciesOpen(o => !o)}
          >
            {speciesOpen ? '▼' : '►'} Species Information
          </Box>
          {speciesOpen && (
            <LabeledList>
              {isKnown(clan) && clan !== "None" && clan !== "Unknown" &&
                <LabeledList.Item label="Clan">{clan}</LabeledList.Item>}
              {isKnown(generation) && generation !== 13 && generation !== "13" &&
                <LabeledList.Item label="Generation">{generation}</LabeledList.Item>}
              {isKnown(masquerade) &&
                <LabeledList.Item label="Masquerade">{masquerade}</LabeledList.Item>}
              {(isKnown(morality_path) || isKnown(morality_score)) && (
                <LabeledList.Item label="Path">
                  {isKnown(morality_path) ? morality_path : "Unknown"}
                  {isKnown(morality_score) ? ` (${morality_score})` : ""}
                </LabeledList.Item>
              )}
            </LabeledList>
          )}
        </Box>
      )}

      {/* Collapsible Disciplines */}
      <Box mt={2}>
        <Box
          bold
          underline
          style={{ cursor: 'pointer', userSelect: 'none' }}
          onClick={() => setDisciplinesOpen(o => !o)}
        >
          {disciplinesOpen ? '▼' : '►'} Disciplines
        </Box>
        {disciplinesOpen && (Array.isArray(disciplines) && disciplines.length > 0 ? (
          <Table>
            {disciplines.map((d, i) =>
              <Table.Row key={i}>
                <Table.Cell bold>{d.name}</Table.Cell>
                <Table.Cell>Lv. {d.level}</Table.Cell>
                <Table.Cell>{d.desc}</Table.Cell>
              </Table.Row>
            )}
          </Table>
        ) : (
          <Box italic>No disciplines known.</Box>
        ))}
      </Box>

      {/* Bonded/Regnant display */}
      {(regnant || regnant_clan) && (regnant !== "Unknown" || regnant_clan !== "Unknown") && (
        <Box mt={3}>
          <Box bold underline>(Bonded)</Box>
          {regnant && regnant !== "Unknown" && <Box><b>Regnant:</b> {regnant}</Box>}
          {regnant_clan && regnant_clan !== "Unknown" && <Box><b>Regnant Clan:</b> {regnant_clan}</Box>}
        </Box>
      )}
    </Section>
  );
};






// ====================
// CollapsibleCategory & EntryCard
// ====================
// Shared utility components for collapsible sections and pretty entry displays (Groups, Relationships, etc.)
const CollapsibleCategory = ({ label, open, onClick, children }) => (
  <Box mb={1}>
    <Box style={{ cursor: 'pointer', fontWeight: 'bold' }} onClick={onClick} underline>
      {open ? '▼' : '►'} {label}
    </Box>
    {open && <Box mt={1}>{children}</Box>}
  </Box>
);

const EntryCard = ({ icon, name, subtitle, desc, fields = [], buttons = [], strength }) => (
  <Box mb={2} style={{ border: '1px solid #333', borderRadius: 6, padding: 8 }}>
    <Box bold mb={1}>
      {icon && <img src={icon} alt="icon" style={{ height: 24, verticalAlign: 'middle', marginRight: 6 }} />}
      {name}
      {subtitle && <span style={{ color: '#aaa', fontWeight: 400, marginLeft: 8 }}>{subtitle}</span>}
      {typeof strength === 'number' &&
        <span style={{ float: 'right', fontWeight: 'bold', color: strength >= 50 ? '#8dbb36ff' : '#bbb' }}>{strength}</span>}
    </Box>
    {desc && <Box mb={1} italic>{desc}</Box>}
    {fields.map(({ label, value }, i) =>
      <Box mb={1} key={i}><b>{label}:</b> {value}</Box>
    )}
    {buttons.length > 0 && (
      <Box mt={1}>
        {buttons.map((btn, i) => React.cloneElement(btn, { key: i, mr: 1 }))}
      </Box>
    )}
  </Box>
);

// ====================
// Groups Tab Section
// ====================
// Shows all groups the character is a member of, grouped by type (city, clan, etc.)
const GROUP_TYPES_UI = [
  { key: 'city', label: 'City' },
  { key: 'faction', label: 'Faction' },
  { key: 'sect', label: 'Sect' },
  { key: 'clan', label: 'Clan' },
  { key: 'tribe', label: 'Tribe' },
  { key: 'organization', label: 'Organization' },
  { key: 'party', label: 'Coterie/Party' },
  { key: 'player_created', label: 'Player Group' },
];

const prettifyGroupType = type =>
  (type ? type.charAt(0).toUpperCase() + type.slice(1).replace(/_/g, ' ') : 'Other');

const groupByType = groupList => {
  const byType = {};
  (Array.isArray(groupList) ? groupList : []).forEach(group => {
    if (group?.type) (byType[group.type] ??= []).push(group);
  });
  return byType;
};

const GroupsSection = ({ groups = {}, act }) => {
  const [openGroup, setOpenGroup] = useLocalState('aboutme_groupopen', '');
  let groupList = [];
  if (Array.isArray(groups)) groupList = groups;
  else if (groups?.group_objects) groupList = Object.values(groups.group_objects).flat();
  else if (typeof groups === 'object') groupList = Object.values(groups).flat();
  const grouped = groupByType(groupList);
  const noGroups = !groupList.length;
  const knownKeys = GROUP_TYPES_UI.map(x => x.key);
  const standardRendered = GROUP_TYPES_UI.map(({ key, label }) => {
    const gList = grouped[key] || [];
    return gList.length ? (
      <CollapsibleCategory
        key={key}
        label={label}
        open={openGroup === key}
        onClick={() => setOpenGroup(openGroup === key ? '' : key)}
      >
        {gList.map((group, i) => (
          <EntryCard
            key={group.id || i}
            name={group.name}
            desc={group.desc}
            subtitle={prettifyGroupType(group.type)}
            fields={[
              { label: 'Status', value: group.orders || '"(Words from the leader.)"' },
              { label: 'Leaders', value: Array.isArray(group.leaders) && group.leaders.length ? group.leaders.join(', ') : (group.leader_name || 'None') },
              { label: 'Officers', value: Array.isArray(group.officers) && group.officers.length ? group.officers.join(', ') : (group.officer_name || 'None') },
              { label: 'Members', value: Array.isArray(group.members) && group.members.length ? group.members.join(', ') : 'None' },
            ]}
          />
        ))}
      </CollapsibleCategory>
    ) : null;
  });

  const unknownTypes = Object.keys(grouped).filter(k => !knownKeys.includes(k));
  const unknownRendered = unknownTypes.map(key => {
    const gList = grouped[key] || [];
    return gList.length ? (
      <CollapsibleCategory
        key={key}
        label={prettifyGroupType(key)}
        open={openGroup === key}
        onClick={() => setOpenGroup(openGroup === key ? '' : key)}
      >
        {gList.map((group, i) => (
          <EntryCard
            key={group.id || i}
            name={group.name}
            desc={group.desc}
            subtitle={prettifyGroupType(group.type)}
            fields={[
              { label: 'Leaders', value: Array.isArray(group.leaders) && group.leaders.length ? group.leaders.join(', ') : (group.leader_name || 'None') },
              { label: 'Officers', value: Array.isArray(group.officers) && group.officers.length ? group.officers.join(', ') : (group.officer_name || 'None') },
              { label: 'Members', value: Array.isArray(group.members) && group.members.length ? group.members.join(', ') : 'None' },
            ]}
          />
        ))}
      </CollapsibleCategory>
    ) : null;
  });

  return (
    <Section title="Groups">
      <Box mb={1}>
        <Button icon="wrench" content="Manage Groups" onClick={() => act('manage_groups')} mb={2} />
      </Box>
      {standardRendered}
      {unknownRendered}
      {noGroups && <Box italic>No groups joined.</Box>}
      <Box mt={3} italic>
        Player Made Groups, Coteries/Squad/Organizations are on the way!
      </Box>
    </Section>
  );
};

// ====================
// Relationships Tab Section
// ====================
const REL_TYPE_UI = [
  { key: 'city', label: 'City' },
  { key: 'faction', label: 'Faction' },
  { key: 'sect', label: 'Sect' },
  { key: 'clan', label: 'Clan' },
  { key: 'tribe', label: 'Tribe' },
  { key: 'organization', label: 'Organization' },
  { key: 'party', label: 'Coterie/Party' },
  { key: 'group', label: 'Group' }, // Optional, only if you use "group" as a fallback
];

const groupRelationshipsByType = relList => {
  const byType = {};
  (Array.isArray(relList) ? relList : []).forEach(rel => {
    const t = rel?.relationship_type || 'other';
    (byType[t] ??= []).push(rel);
  });
  return byType;
};

const RelationshipsSection = ({ relationships = [], act }) => {
  const [openType, setOpenType] = useLocalState('aboutme_reltype_open', '');
  let relArray = Array.isArray(relationships) ? relationships : [];

  const grouped = groupRelationshipsByType(relArray);
  const noRels = !relArray.length;
  const knownKeys = REL_TYPE_UI.map(x => x.key);

  const standardRendered = REL_TYPE_UI.map(({ key, label }) => {
    const rels = grouped[key] || [];
    return rels.length ? (
      <CollapsibleCategory
        key={key}
        label={label}
        open={openType === key}
        onClick={() => setOpenType(openType === key ? '' : key)}
      >
        {rels.map((rel, i) =>
          <EntryCard
            key={rel.id || i}
            name={rel.name}
            subtitle={prettifyGroupType(rel.relationship_type)}
            desc={rel.desc}
            strength={rel.strength}
            fields={[]}
          />
        )}
      </CollapsibleCategory>
    ) : null;
  });

  const unknownTypes = Object.keys(grouped).filter(k => !knownKeys.includes(k));
  const unknownRendered = unknownTypes.map(key => {
    const rels = grouped[key] || [];
    return rels.length ? (
      <CollapsibleCategory
        key={key}
        label={prettifyGroupType(key)}
        open={openType === key}
        onClick={() => setOpenType(openType === key ? '' : key)}
      >
        {rels.map((rel, i) =>
          <EntryCard
            key={rel.id || i}
            name={rel.name}
            subtitle={prettifyGroupType(rel.relationship_type)}
            desc={rel.desc}
            strength={rel.strength}
            fields={[]}
          />
        )}
      </CollapsibleCategory>
    ) : null;
  });

  return (
    <Section title="Relationships">
      {standardRendered}
      {unknownRendered}
      {noRels && <Box italic>No relationships defined.</Box>}
      <Box mt={2}>
        <Button icon="wrench" content="Change Relationship" onClick={() => act('change_relationship')} mb={2} />
      </Box>
    </Section>
  );
};

// ====================
// Chronicle Tab Section
// ====================

const ChronicleSection = ({ chronicleEvents = [], act }) => {
  const [open, setOpen] = useLocalState('aboutme_chronicle_open', true);
  const events = Array.isArray(chronicleEvents) ? chronicleEvents : [];

  const formatDateRange = (start, end) => {
    if (start && end) return `${start} → ${end}`;
    if (start) return `Started: ${start}`;
    if (end) return `Ended: ${end}`;
    return "—";
  };

  return (
    <Section title="Chronicle (Events)">
      <CollapsibleCategory
        label={`Chronicle Events (${events.length})`}
        open={open}
        onClick={() => setOpen(o => !o)}
      >
        {events.length ? events.map((entry, i) => (
          <EntryCard
            key={entry.id || i}
            name={entry.title || `Event #${i + 1}`}
            subtitle={`${entry.ctype || "Event"} • ${formatDateRange(entry.date_started, entry.date_ended)}`}
            desc={
              <>
                <Box>{entry.desc || "(No description provided.)"}</Box>
                {!!entry.related_characters?.length && (
                  <Box mt={1}><b>Characters:</b> {entry.related_characters.join(", ")}</Box>
                )}
                {!!entry.related_groups?.length && (
                  <Box><b>Groups:</b> {entry.related_groups.join(", ")}</Box>
                )}
              </>
            }
          />
        )) : <Box italic>No chronicle entries yet.</Box>}
      </CollapsibleCategory>

      <Box mt={2}>
        <Button
          icon="wrench"
          content="Interact With Chronicle"
          onClick={() => act('interact_chronicle')}
        />
      </Box>
    </Section>
  );
};


const MEMORY_TAGS_UI = [
  { value: 'all', text: 'All Memories' },
  { value: 'background', text: 'Background' },
  { value: 'current', text: 'Current' },
  { value: 'recent', text: 'Recent' },
  { value: 'goal', text: 'Goals' },
  { value: 'secret', text: 'Secrets' },
  { value: 'reputation', text: 'Reputation' },
  { value: 'relationship', text: 'Relationships' },
  { value: 'character_memories', text: 'Character Memories' },
];

const MemoriesTabsSection = ({ memories = {}, act }) => {
  const [memTab, setMemTab] = useLocalState('aboutme_memtab', 'all');
  const [open, setOpen] = useLocalState('aboutme_memories_open', true);

  // Normalize structure
  const memObj = Array.isArray(memories)
    ? { memories_all: memories }
    : (memories || {});

  const tagFiltered = memTab === 'all'
    ? Array.isArray(memObj.memories_all) ? memObj.memories_all : []
    : Array.isArray(memObj[memTab]) ? memObj[memTab] : [];

  return (
    <Section title="Memories">
      <Box mb={2}>
        <label htmlFor="memories-dropdown"><b>Filter by Type:</b> </label>
        <select
          id="memories-dropdown"
          value={memTab}
          onChange={e => setMemTab(e.target.value)}
          style={{ marginLeft: 8, minWidth: 140 }}
        >
          {MEMORY_TAGS_UI.map(({ value, text }) => (
            <option key={value} value={value}>{text}</option>
          ))}
        </select>
        <Button
          icon="wrench"
          content="Manage Memories"
          onClick={() => act('manage_memories')}
          ml={2}
        />
      </Box>
      <CollapsibleCategory
        label="Memories List"
        open={open}
        onClick={() => setOpen(o => !o)}
      >
        {tagFiltered.length ? tagFiltered.map((mem, i) => (
          <EntryCard
            key={mem.id || i}
            name={mem.summary || `Memory #${i + 1}`}
            subtitle={mem.date_occurred || "—"}
            desc={mem.details || ""}
            fields={[
              {
                label: 'Tags',
                value: Array.isArray(mem.tags) && mem.tags.length
                  ? mem.tags.join(', ')
                  : <span style={{ color: '#aaa', fontStyle: 'italic' }}>No tags</span>
              },
              {
                label: 'Status',
                value: mem.status || <span style={{ color: '#aaa', fontStyle: 'italic' }}>—</span>
              }
            ]}
          />
        )) : (
          <Box italic>No memories in this category.</Box>
        )}
      </CollapsibleCategory>
    </Section>
  );
};


// ====================
// Main AboutMeInt UI
// ====================
export const AboutmeInt = (props, context) => {
  const { data = {}, act } = useBackend(context);

  // Defensive everywhere!
  const overview = data.overview ?? {};
  const groups = data.groups ?? {};

  // Relationships: array or .group_affiliations fallback
  const relationships = Array.isArray(data.relationships)
    ? data.relationships
    : (data.relationships?.group_affiliations ?? []);

  // Chronicle: array or .events fallback
  const chronicleEvents = Array.isArray(data.chronicle)
    ? data.chronicle
    : (data.chronicle?.events ?? []);

  // Memories: canonical object, fallback to categories, fallback to []
  const memories = Array.isArray(data.memories)
    ? { memories_all: data.memories }
    : (data.memories ?? {
        memories_all: data.memories_all ?? [],
        background: data.background ?? [],
        current: data.current ?? [],
        recent: data.recent ?? [],
        goal: data.goal ?? [],
        secret: data.secret ?? [],
        reputation: data.reputation ?? [],
      });

  const [tab, setTab] = useLocalState('aboutme_tab', 'overview');

  return (
    <Window width={400} height={650} title="About My Character (Early Testing)">
      <Window.Content scrollable>
        <Box italic mb={2}>
          <details open>
            <summary>Welcome to the New About Me Panel! (Early Testing)</summary>
            <div style={{ marginTop: 8 }}>
              WARNING: Only Round to Round for now. Take Screenshots!<br />
              Tabs: Each tab has a Button leading to Branching Options!<br />
              Overview! Veiw and Manage your character details! <br />
              Groups! Manage and interact with your groups! <br />
              Relationships! Manage your group and personal relationships! <br />
              Chronicles! Interact with your, or a group's, chronicle! <br />
              Memories! Share, create, and manage your memories! <br />
              Give us feedback to help us sort out any issues! <br />
              Explore, see whats possible! <br />
            </div>
          </details>
        </Box>
        <Tabs>
          <Tabs.Tab selected={tab === 'overview'} onClick={() => setTab('overview')}>Overview</Tabs.Tab>
          <Tabs.Tab selected={tab === 'groups'} onClick={() => setTab('groups')}>Groups</Tabs.Tab>
          <Tabs.Tab selected={tab === 'relationships'} onClick={() => setTab('relationships')}>Relationships</Tabs.Tab>
          <Tabs.Tab selected={tab === 'chronicle'} onClick={() => setTab('chronicle')}>Chronicle</Tabs.Tab>
          <Tabs.Tab selected={tab === 'memories'} onClick={() => setTab('memories')}>Memories</Tabs.Tab>
        </Tabs>
          <Box mt={2}>
            {tab === 'overview' && (
              <>
                <Box italic mb={1}>View, access, and edit your core character details, mid-round. (Very Expandable Features Pending! Like Path Management. Masquerade management by faction leaders, and more!)</Box>
                <OverviewSection overview={overview} status={data.status} alignment={data.alignment} act={act} />
              </>
            )}
            {tab === 'groups' && (
              <>
                <Box italic mb={1}>Join, Leave, Create or Manage Groups, based on group-role. All Public Organizations/Parties are public human-facing. (Status, is a statement by the leader, of the group's current objective, meant to be easily obtained through the "gravevine" of the group. Leaders may use parties for orders instead.)</Box>
                <GroupsSection groups={groups} act={act} currentCkey={overview?.general?.name || ''} />
              </>
            )}
            {tab === 'relationships' && (
              <>
                <Box italic mb={1}>See how your character relates to others as well as group loyalties and ties based on your character and role.</Box>
                <RelationshipsSection relationships={relationships} act={act} />
              </>
            )}
            {tab === 'chronicle' && (
              <>
                <Box italic mb={1}>Record, share, and explore major group-wide, shared, or personal events.</Box>
                <ChronicleSection chronicleEvents={chronicleEvents} act={act} />
              </>
            )}
            {tab === 'memories' && (
              <>
                <Box italic mb={1}>Create, track, and share character memories you've experienced, in this round. (Warning: No round to round saving is implimented, yet.)</Box>
                <MemoriesTabsSection memories={memories} act={act} />
              </>
            )}
          </Box>

        <Box mt={3}>
          <details>
            <summary>Debug: Full Payload</summary>
            <pre style={{
              maxHeight: 180,
              overflowY: 'auto',
              fontSize: 12,
              background: '#111',
              color: '#eee',
              borderRadius: 4,
              padding: 8
            }}>
              {JSON.stringify(data, null, 2)}
            </pre>
          </details>

        </Box>
      </Window.Content>
    </Window>
  );

};

AboutmeInt.displayName = 'AboutmeInt';
AboutmeInt.defaultProps = {
  id: 'AboutmeInt',
  title: 'About Me',
};
