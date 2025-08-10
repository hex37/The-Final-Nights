// THIS IS A TFN UI FILE
import React from 'react';
import {
  Box, Button, LabeledList, Section, Tabs,
} from 'tgui-core/components';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

export const AboutmeInt = (props, context) => {
  const { data = {}, act } = useBackend(context);

  // Tab control
  const [tab, setTab] = useLocalState('aboutme_tab', 'overview');
  const [debugOpen, setDebugOpen] = useLocalState('aboutme_debug_open', false);

  // Data for each section
  const overview = data.overview ?? {};
  const groups = data.groups ?? {};
  const relationships = data.relationships ?? [];
  const chronicleEvents = (data.chronicle && data.chronicle.events) || [];
  const memories = data.memories ?? {};

  // --- Section Renderers ---

  const renderOverview = () => {
    const gen = (overview.general || {});
    const species = (overview.species || {});

    // Filter out empty species data except disciplines/gifts
    const speciesEntries = Object.entries(species).filter(([k, v]) => {
      if (k === 'disciplines' || k === 'gifts') return false;
      if (v === undefined || v === null) return false;
      if (typeof v === 'string' && (!v.trim() || v.trim().toLowerCase() === 'unknown' || v.trim().toLowerCase() === 'none')) return false;
      if (Array.isArray(v) && v.length === 0) return false;
      return true;
    });

    const hasAttributes = gen.stats && Object.keys(gen.stats).length > 0;
    const hasSpeciesBlock = speciesEntries.length > 0;
    const hasDisciplines = Array.isArray(species.disciplines) && species.disciplines.length > 0;
    const hasGifts = Array.isArray(species.gifts) && species.gifts.length > 0;

    // Build available tabs
    const subTabs = [
      hasAttributes && { key: 'attributes', label: 'Attributes' },
      hasSpeciesBlock && { key: 'species', label: 'Species' },
      hasDisciplines && { key: 'disciplines', label: 'Disciplines' },
      hasGifts && { key: 'gifts', label: 'Gifts' },
    ].filter(Boolean);

    // Remember the current open subtabs
    const [subTab, setSubTab] = useLocalState('aboutme_overview_subtab', subTabs[0]?.key || '');

    return (
      <Section
        title={
          <Box style={{ display: 'flex', alignItems: 'center' }}>
            <Box style={{ fontWeight: 'bold', fontSize: 16 }}>Overview</Box>
            <Box ml="auto">
              <Button
                icon="edit"
                content="Edit Overview"
                size="small"
                onClick={() => act('edit_overview')}
                style={{ marginLeft: 12, marginBottom: 0 }}
              />
            </Box>
          </Box>
        }
        fill
      >
        <LabeledList>
          <LabeledList.Item label="Name">{gen.name || 'Unknown'}</LabeledList.Item>
          <LabeledList.Item label="Role">{gen.role || 'Unknown'}</LabeledList.Item>
          <LabeledList.Item label="Species">{gen.species || 'Unknown'}</LabeledList.Item>
          <LabeledList.Item label="Gender">{gen.gender || '—'}</LabeledList.Item>
          <LabeledList.Item label="Physical Desc">{gen.physical_desc || '—'}</LabeledList.Item>
          <LabeledList.Item label="Goals">{gen.goals || '—'}</LabeledList.Item>
          <LabeledList.Item label="Personal Quote">{gen.personal_quote || '—'}</LabeledList.Item>
          <LabeledList.Item label="Bank Code">{gen.bank_account_code || '—'}</LabeledList.Item>
        </LabeledList>

        {/* Sub-tabs for extra info */}
        {subTabs.length > 0 && (
          <>
            <Tabs mb={2}>
              {subTabs.map(tabObj => (
                <Tabs.Tab
                  key={tabObj.key}
                  selected={subTab === tabObj.key}
                  onClick={() => setSubTab(tabObj.key)}
                >
                  {tabObj.label}
                </Tabs.Tab>
              ))}
            </Tabs>
            <Box>
              {subTab === 'attributes' && hasAttributes && (
                <LabeledList>
                  {Object.entries(gen.stats).map(([k, v]) => (
                    <LabeledList.Item key={k} label={k}>{v}</LabeledList.Item>
                  ))}
                </LabeledList>
              )}
              {subTab === 'species' && hasSpeciesBlock && (
                <LabeledList>
                  {speciesEntries.map(([k, v]) => (
                    <LabeledList.Item
                      key={k}
                      label={k.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}
                    >
                      {v}
                    </LabeledList.Item>
                  ))}
                </LabeledList>
              )}
              {subTab === 'disciplines' && hasDisciplines && (
                <ul style={{ margin: 0, paddingLeft: 18 }}>
                  {species.disciplines.map((d, i) => (
                    <li key={i}>
                      <b>{d.name}</b> (Lv.{d.level}){d.desc ? <>: <span style={{ color: '#ccc' }}>{d.desc}</span></> : null}
                    </li>
                  ))}
                </ul>
              )}
              {subTab === 'gifts' && hasGifts && (
                <ul style={{ margin: 0, paddingLeft: 18 }}>
                  {species.gifts.map((g, i) => (
                    <li key={i}>
                      <b>{typeof g.name === 'string'
                        ? g.name.replace('/datum/action/gift/', '').replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())
                        : g.name}</b>
                      {g.desc ? <>: <span style={{ color: '#ccc' }}>{g.desc}</span></> : null}
                    </li>
                  ))}
                </ul>
              )}
            </Box>
          </>
        )}
      </Section>
    );
  };




const renderGroups = () => {
  // Flatten { type: [ ...groups ] } -> [ ...groups ]
  let groupList = [];
  if (groups.group_objects && typeof groups.group_objects === 'object') {
    groupList = Object.entries(groups.group_objects).flatMap(([gtype, arr]) =>
      Array.isArray(arr) ? arr.map(g => ({
        ...g,
        group_type: g.group_type || gtype, // ensure present for UI
      })) : []
    );
  } else if (Array.isArray(groups)) {
    groupList = groups;
  } else if (groups && typeof groups === 'object') {
    groupList = Object.values(groups).flat();
  }

  const [openIndex, setOpenIndex] = useLocalState('aboutme_group_open', -1);

  return (
    <Section
      title={
        <Box style={{ display: 'flex', alignItems: 'center' }}>
          <Box style={{ fontWeight: 'bold', fontSize: 16 }}>Groups</Box>
          <Box ml="auto">
            <Button
              icon="wrench"
              content="Manage Groups"
              size="small"
              onClick={() => act('manage_groups')}
              style={{ marginLeft: 12, marginBottom: 0 }}
            />
          </Box>
        </Box>
      }
      fill
    >
      {groupList.length === 0 && <Box italic>No groups joined.</Box>}
      {groupList.map((group, i) => {
        const typeLabel = (group.group_type || group.type || 'group');
        const typePretty = typeLabel.charAt(0).toUpperCase() + typeLabel.slice(1);
        const leaderName = group.leader_name || (Array.isArray(group.leaders) && group.leaders[0]) || '—';
        const memberNames = (group.member_names || group.members || []);
        return (
          <Box
            key={`${group.id || i}`}
            mb={2}
            style={{
              border: '1px solid #333',
              borderRadius: 4,
              background: openIndex === i ? '#191f21' : '#151719',
              boxShadow: openIndex === i ? '0 0 6px #aaa2' : 'none',
              cursor: 'pointer',
              transition: 'background 0.13s',
            }}
          >
            <Box
              bold
              p={1}
              style={{ display: 'flex', alignItems: 'center' }}
              onClick={() => setOpenIndex(openIndex === i ? -1 : i)}
            >
              <Box mr={2} style={{
                width: 24, textAlign: 'center',
                color: openIndex === i ? '#8dbb36ff' : '#bbb',
                fontWeight: 900,
              }}>
                {openIndex === i ? '▼' : '►'}
              </Box>
              <Box mr={2}>{group.name || 'Group'}</Box>
              <Box ml="auto" italic style={{ color: '#6cf', fontWeight: 400 }}>
                {typePretty}
              </Box>
            </Box>
            {openIndex === i && (
              <Box p={2} pt={1}>
                <Box mb={1} style={{ color: '#bbb' }}>{group.desc}</Box>
                <LabeledList>
                  <LabeledList.Item label="Leader">{leaderName}</LabeledList.Item>
                  <LabeledList.Item label="Members">
                    {memberNames.length ? memberNames.join(', ') : '—'}
                  </LabeledList.Item>
                  {/* Orders removed per new payload */}
                </LabeledList>
              </Box>
            )}
          </Box>
        );
      })}
    </Section>
  );
};



  const renderRelationships = () => {
    const [openIndex, setOpenIndex] = useLocalState('aboutme_relationship_open', -1);

    // Split relationships (UI-only)
    const personal = relationships.filter(rel => rel.target_type !== 'group');
    const group = relationships.filter(rel => rel.target_type === 'group');

    const makeAccordion = (rels, sectionLabel, sectionColor) =>
      rels.length > 0 && (
        <Section title={sectionLabel} fill>
          {rels.map((rel, i) => {
            const idx = sectionLabel + i;
            return (
              <Box
                key={idx}
                mb={2}
                style={{
                  border: '1px solid #333',
                  borderRadius: 4,
                  background: openIndex === idx ? '#191f21' : '#151719',
                  boxShadow: openIndex === idx ? '0 0 6px #aaa2' : 'none',
                  cursor: 'pointer',
                  transition: 'background 0.13s',
                }}
              >
                <Box
                  bold
                  p={1}
                  style={{ display: 'flex', alignItems: 'center' }}
                  onClick={() => setOpenIndex(openIndex === idx ? -1 : idx)}
                >
                  <Box mr={2} style={{
                    width: 24, textAlign: 'center',
                    color: openIndex === idx ? sectionColor : '#bbb',
                    fontWeight: 900,
                  }}>
                    {openIndex === idx ? '▼' : '►'}
                  </Box>
                  <Box mr={2}>{rel.name}</Box>
                  <Box ml="auto" italic style={{ color: '#6cf', fontWeight: 400 }}>
                    {rel.rtype ? rel.rtype.charAt(0).toUpperCase() + rel.rtype.slice(1) : 'Relationship'}
                  </Box>
                </Box>
                {openIndex === idx && (
                  <Box p={2} pt={1}>
                    <Box mb={1} style={{ color: '#bbb' }}>{rel.desc}</Box>
                    <LabeledList>
                      <LabeledList.Item label="Strength">{rel.strength || '—'}</LabeledList.Item>
                      <LabeledList.Item label="Target">
                        {rel.target || rel.name || rel.target_key || '—'}
                      </LabeledList.Item>
                      <LabeledList.Item label="Date">
                        {rel.date_created || rel.created_at || '—'}
                      </LabeledList.Item>
                    </LabeledList>
                  </Box>
                )}
              </Box>
            );
          })}
        </Section>
      );

    return (
      <Section
        title={
          <Box style={{ display: 'flex', alignItems: 'center' }}>
            <Box style={{ fontWeight: 'bold', fontSize: 16 }}>Relationships</Box>
            <Box ml="auto">
              <Button
                icon="wrench"
                content="Change Relationship"
                size="small"
                onClick={() => act('change_relationship')}
                style={{ marginLeft: 12, marginBottom: 0 }}
              />
            </Box>
          </Box>
        }
        fill
      >
        {personal.length === 0 && group.length === 0 && <Box italic>No relationships.</Box>}
        {makeAccordion(personal, 'Personal Relationships', '#6cfc9e')}
        {makeAccordion(group, 'Group Relationships', '#6cf')}
      </Section>
    );
  };

  const renderChronicle = () => {
    const [openIndex, setOpenIndex] = useLocalState('aboutme_chronicle_open', -1);

    return (
      <Section
        title={
          <Box style={{ display: 'flex', alignItems: 'center' }}>
            <Box style={{ fontWeight: 'bold', fontSize: 16 }}>Chronicle</Box>
            <Box ml="auto">
              <Button
                icon="wrench"
                content="Interact With Chronicle"
                size="small"
                onClick={() => act('interact_chronicle')}
                style={{ marginLeft: 12, marginBottom: 0 }}
              />
            </Box>
          </Box>
        }
        fill
      >
        {chronicleEvents.length === 0 && <Box italic>No events yet.</Box>}
        {chronicleEvents.map((event, i) => (
          <Box
            key={i}
            mb={2}
            style={{
              border: '1px solid #333',
              borderRadius: 4,
              background: openIndex === i ? '#191f21' : '#151719',
              boxShadow: openIndex === i ? '0 0 6px #aaa2' : 'none',
              cursor: 'pointer',
              transition: 'background 0.13s',
            }}
          >
            <Box
              bold
              p={1}
              style={{ display: 'flex', alignItems: 'center' }}
              onClick={() => setOpenIndex(openIndex === i ? -1 : i)}
            >
              <Box mr={2} style={{
                width: 24, textAlign: 'center',
                color: openIndex === i ? '#ffe080' : '#bbb',
                fontWeight: 900,
              }}>
                {openIndex === i ? '▼' : '►'}
              </Box>
              <Box mr={2}>{event.title || `Event #${i + 1}`}</Box>
              <Box ml="auto" italic style={{ color: '#ffc', fontWeight: 400 }}>
                {event.ctype ? event.ctype.charAt(0).toUpperCase() + event.ctype.slice(1) : 'Event'}
              </Box>
            </Box>
            {openIndex === i && (
              <Box p={2} pt={1}>
                <Box mb={1} style={{ color: '#bbb' }}>{event.desc}</Box>
                <LabeledList>
                  <LabeledList.Item label="Characters">{(event.related_characters || []).join(', ') || '—'}</LabeledList.Item>
                  <LabeledList.Item label="Groups">{(event.related_groups || []).join(', ') || '—'}</LabeledList.Item>
                </LabeledList>
              </Box>
            )}
          </Box>
        ))}
      </Section>
    );
  };


  const renderMemories = () => {
    const all = (memories.memories_all || []);
    const [openIndex, setOpenIndex] = useLocalState('aboutme_memories_open', -1);

    return (
      <Section
        title={
          <Box style={{ display: 'flex', alignItems: 'center' }}>
            <Box style={{ fontWeight: 'bold', fontSize: 16 }}>Memories</Box>
            <Box ml="auto">
              <Button
                icon="wrench"
                content="Manage Memories"
                size="small"
                onClick={() => act('manage_memories')}
                style={{ marginLeft: 12, marginBottom: 0 }}
              />
            </Box>
          </Box>
        }
        fill
      >
        {all.length === 0 && <Box italic>No memories yet.</Box>}
        {all.map((mem, i) => (
          <Box
            key={i}
            mb={2}
            style={{
              border: '1px solid #333',
              borderRadius: 4,
              background: openIndex === i ? '#23281f' : '#1b1d18',
              boxShadow: openIndex === i ? '0 0 6px #accb3622' : 'none',
              cursor: 'pointer',
              transition: 'background 0.13s',
            }}
          >
            <Box
              bold
              p={1}
              style={{ display: 'flex', alignItems: 'center' }}
              onClick={() => setOpenIndex(openIndex === i ? -1 : i)}
            >
              <Box mr={2} style={{
                width: 24, textAlign: 'center',
                color: openIndex === i ? '#aee' : '#7a9',
                fontWeight: 900,
              }}>
                {openIndex === i ? '▼' : '►'}
              </Box>
              <Box mr={2}>{mem.summary || `Memory #${i + 1}`}</Box>
              <Box ml="auto" italic style={{ color: '#ace', fontWeight: 400 }}>
                {mem.date_occurred || '—'}
              </Box>
            </Box>
            {openIndex === i && (
              <Box p={2} pt={1}>
                <Box mb={1} style={{ color: '#bbb' }}>{mem.details}</Box>
                <LabeledList>
                  <LabeledList.Item label="Tags">{(mem.tags || []).join(', ') || '—'}</LabeledList.Item>
                  <LabeledList.Item label="Status">{mem.status || '—'}</LabeledList.Item>
                </LabeledList>
              </Box>
            )}
          </Box>
        ))}
      </Section>
    );
  };


  // --- Main Render ---

  return (
    <Window title="About Me" width={480} height={540}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab selected={tab === 'overview'} onClick={() => setTab('overview')}>Overview</Tabs.Tab>
          <Tabs.Tab selected={tab === 'groups'} onClick={() => setTab('groups')}>Groups</Tabs.Tab>
          <Tabs.Tab selected={tab === 'relationships'} onClick={() => setTab('relationships')}>Relationships</Tabs.Tab>
          <Tabs.Tab selected={tab === 'chronicle'} onClick={() => setTab('chronicle')}>Chronicle</Tabs.Tab>
          <Tabs.Tab selected={tab === 'memories'} onClick={() => setTab('memories')}>Memories</Tabs.Tab>
        </Tabs>
        <Box mt={2}>
          {tab === 'overview' && renderOverview()}
          {tab === 'groups' && renderGroups()}
          {tab === 'relationships' && renderRelationships()}
          {tab === 'chronicle' && renderChronicle()}
          {tab === 'memories' && renderMemories()}
        </Box>
        <Box mt={3}>
          <Button
            icon={debugOpen ? 'caret-down' : 'caret-right'}
            content="Debug Payload"
            color={debugOpen ? 'average' : undefined}
            onClick={() => setDebugOpen(!debugOpen)}
            mb={1}
          />
          {debugOpen && (
            <Box
              style={{
                fontFamily: 'monospace',
                fontSize: 12,
                background: '#181c1f',
                color: '#aee',
                borderRadius: 3,
                padding: 8,
                whiteSpace: 'pre-wrap',
                maxHeight: 180,
                overflowY: 'auto',
              }}>
              {JSON.stringify(data, null, 2)} //data dump for quick debugging
            </Box>
          )}
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
