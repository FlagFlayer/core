/* Copyright (C) 2006 - 2009 ScriptDev2 <https://scriptdev2.svn.sourceforge.net/>
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* ScriptData
SDName: Boss_Anubrekhan
SD%Complete: 90
SDComment: Check timers for corpse explosion of Crypt Guards. Currently not correct.
           Locust Swarm timers could use more sources.
           Damage and armor of boss, crypt guards and corpse scarabs needs research.
           Anubs hitbox is probably too small.
SDCategory: Naxxramas
EndScriptData */

#include "scriptPCH.h"
#include "naxxramas.h"
#include <vector>

// todo:
/*
Armor check:
https://www.youtube.com/watch?v=rmowgw2SZCA&t=60s
*/

enum AnubrekhanData
{
    SAY_GREET1                  = 13004,
    SAY_GREET2                  = 13006,
    SAY_GREET3                  = 13007,
    SAY_GREET4                  = 13008,
    SAY_GREET5                  = 13009,
    SAY_AGGRO1                  = 13000,
    SAY_AGGRO2                  = 13002,
    SAY_AGGRO3                  = 13003,
    SAY_SLAY                    = 13005,

    SPELL_DOUBLE_ATTACK         = 18943,
    SPELL_IMPALE                = 28783,
    SPELL_LOCUSTSWARM           = 28785,                    // This is a self buff that triggers the dmg debuff
    SPELL_ANUB_AURA             = 29103,                    // Periodically apply aura 29104 onto players to handle the corpse scarabs summon when they die (spell 29105)

    SPELL_SUMMON_GUARD          = 29508,                    // Summons 1 Crypt Guard at targeted location
    SPELL_DESPAWN_GUARDS        = 29379,                    // Remove all Crypt Guards and Corpse Scarabs
    SPELL_SPAWN_CORPSE_SCARABS  = 28961,                    // Trigger 28864 Summon 10 Corpse Scarabs from dead Crypt Guard

//    SPELL_SELF_SPAWN_5          = 29105,        // These spells should spawn corpse scarabs, but only show the explosion anim.
//    SPELL_SELF_SPAWN_10         = 28864,        // If we fix them to spawn scarbs, code must be changed to not manually spawn them too.
};

struct boss_anubrekhanAI : public ScriptedAI
{
    boss_anubrekhanAI(Creature* pCreature) : ScriptedAI(pCreature)
    {
        m_pInstance = (instance_naxxramas*)pCreature->GetInstanceData();
        if (!m_pInstance)
            sLog.Out(LOG_SCRIPTS, LOG_LVL_ERROR, "boss_anubrekhanAI::ctor failed to cast instanceData to instance_naxxramas");

        haveDoneIntro = false;
        Reset();
    }
    
    instance_naxxramas* m_pInstance;

    uint32 m_uiImpaleTimer;
    uint32 m_uiLocustSwarmTimer;
    uint32 m_uiSummonTimer
    uint32 m_uiCorpseScarabsTimer;
    bool haveDoneIntro;

    void Reset() override
    {
        m_uiImpaleTimer           = 15 * IN_MILLISECONDS;
        m_uiLocustSwarmTimer      = urand(80, 120) * IN_MILLISECONDS;
        m_uiSummonTimer           = 0;
        m_uiCorpseScarabsTimer    = urand(65, 105) * IN_MILLISECONDS;
    }

    void JustReachedHome() override
    {
        if (m_pInstance)
            m_pInstance->SetData(TYPE_ANUB_REKHAN, FAIL);
        
        DoCastSpellIfCan(m_creature, SPELL_DOUBLE_ATTACK, CF_TRIGGERED | CF_AURA_NOT_PRESENT);
    }

    void KilledUnit(Unit* pVictim) override
    {
        // Scarabs are summoned by instance script when a player dies.
        // See instance_naxxramas::OnPlayerDeath(Player*)
        if (pVictim->GetTypeId() != TYPEID_PLAYER)
            return;
        
        DoScriptText(SAY_SLAY, m_creature);
    }

    void Aggro(Unit* pWho) override
    {
        if (!m_pInstance)
            return;
        m_pInstance->SetData(TYPE_ANUB_REKHAN, IN_PROGRESS);
        // Setting in combat with zone
        m_creature->SetInCombatWithZone();

        DoScriptText(PickRandomValue(SAY_AGGRO1, SAY_AGGRO2, SAY_AGGRO3), m_creature);
    }

    void JustDied(Unit* pKiller) override
    {
        if (m_pInstance)
            m_pInstance->SetData(TYPE_ANUB_REKHAN, DONE);
    }

    void JustSummoned(Creature* summoned) override
    {
        summoned->SetInCombatWithZone();
    }
    
    void EnterEvadeMode() override
    {
        // We despawn the guardians before entering evade mode to prevent despawning also the static adds that are linked to respawn on evade
        DoCastSpellIfCan(m_creature, SPELL_DESPAWN_GUARDS, CF_TRIGGERED);

        ScriptedAI::EnterEvadeMode();
    }

    void UpdateAI(uint32 const uiDiff) override
    {
        if (!m_creature->SelectHostileTarget() || !m_creature->GetVictim())
            return;

        if (!m_pInstance->HandleEvadeOutOfHome(m_creature))
            return;

        // Impale
        if (m_uiImpaleTimer < diff)
        {
            // Cast Impale on a random target
            // Do NOT cast it when we are afflicted by locust swarm
            if (!m_creature->HasAura(SPELL_LOCUSTSWARM))
            {
                if (Unit* target = m_creature->SelectAttackingTarget(ATTACKING_TARGET_RANDOM, 0))
                    DoCastSpellIfCan(target, SPELL_IMPALE);
            }

            m_uiImpaleTimer = urand(12, 18) * IN_MILLISECONDS;
        }
        else
            m_uiImpaleTimer -= diff;
        }

       // Locust Swarm
        if (m_uiLocustSwarmTimer < diff)
        {
            if (DoCastSpellIfCan(m_creature, SPELL_LOCUSTSWARM) == CAST_OK)
            {
                // Summon a crypt guard
                m_uiSummonTimer = 3 * IN_MILLISECONDS;
                m_uiLocustSwarmTimer = 90 * IN_MILLISECONDS;
                m_uiImpaleTimer += 23 * IN_MILLISECONDS;    // Delay next Impale by Locust Swarm duration (20 sec) + casting time (3 sec), this prevent Impale to be always cast right after Locust Swarm ends
            }
        }
        else
            m_uiLocustSwarmTimer -= diff;

        // Summon Crypt Guard after Locust Swarm
        if (m_uiSummonTimer)
        {
            if (m_uiSummonTimer <= diff)
            {
                if (DoCastSpellIfCan(m_creature, SPELL_SUMMON_GUARD) == CAST_OK)
                    m_uiSummonTimer = 0;
            }
            else
                m_uiSummonTimer -= diff;
        }
    
    // Summon Corpse Scarabs from dead Crypt Guard
        if (m_corpseScarabsTimer)
        {
            if (m_corpseScarabsTimer <= diff)
            {
                if (DoCastSpellIfCan(nullptr, SPELL_SPAWN_CORPSE_SCARABS) == CAST_OK)
                    m_corpseScarabsTimer = urand(65, 105) * IN_MILLISECONDS;
            }
            else
                m_corpseScarabsTimer -= diff;
        }
        
        DoMeleeAttackIfReady();
    }
};

struct anub_doorAI : public GameObjectAI
{
    instance_naxxramas* m_pInstance;

    anub_doorAI(GameObject* pGo) : GameObjectAI(pGo), haveDoneIntro(false)
    {
        m_pInstance = (instance_naxxramas*)me->GetInstanceData();
        if (!m_pInstance)
            sLog.Out(LOG_SCRIPTS, LOG_LVL_ERROR, "anub_doorAI could not find instanceData");
    }

    bool OnUse(Unit* user) override
    {
        if (haveDoneIntro)
            return false;

        haveDoneIntro = true;

        if (!m_pInstance)
        {
            sLog.Out(LOG_SCRIPTS, LOG_LVL_MINIMAL, "[boss_anubrekhan/anub_doorAI][Inst %03u] ERROR: No instance", user->GetInstanceId());
            return false;
        }

        if (Creature* anubRekhan = m_pInstance->GetSingleCreatureFromStorage(NPC_ANUB_REKHAN))
        {
            if (anubRekhan->IsAlive() && !haveDoneIntro)
            {
                DoScriptText(PickRandomValue(SAY_GREET1, SAY_GREET2, SAY_GREET3, SAY_GREET4, SAY_GREET5), anubRekhan);
                haveDoneIntro = true;
            }
        }
        me->SetFlag(GAMEOBJECT_FLAGS, GO_FLAG_NO_INTERACT);
        return false;
    }
};

CreatureAI* GetAI_boss_anubrekhan(Creature* pCreature)
{
    return new boss_anubrekhanAI(pCreature);
}

GameObjectAI* GetAI_anub_door(GameObject* pGo)
{
    return new anub_doorAI(pGo);
}

void AddSC_boss_anubrekhan()
{
    Script* NewScript;

    NewScript = new Script;
    NewScript->Name = "boss_anubrekhan";
    NewScript->GetAI = &GetAI_boss_anubrekhan;
    NewScript->RegisterSelf();

    NewScript = new Script;
    NewScript->Name = "go_anub_door";
    NewScript->GOGetAI = &GetAI_anub_door;
    NewScript->RegisterSelf();  
}
