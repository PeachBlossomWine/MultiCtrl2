# Multictrl
 
Current commands:  Use //mc

================================================================================
#### Battle Related ####
on: turns on all addons/auto functions from gearswap.  Disabled in town areas.

off: turns off everything.

stage: configures chars depending on battle or jobs (ie. Lilith, BRD will set songs for singer for Lilith)

fight: fight distance where magee's are further back on follow.  Uses healbot

fightmage:  Everyone but current char is at mage distance (18)

fightsmall:  Everyone close quarters fighting

ws: Toggles autows to be on or off.  Uses Selindrile's GS

food: Uses preset food.

sleep: Toggle anti sleep mode for /SCH sub, a variable toggle, needs custom GS code into Selindrile's.

fin: Jobs that can dispel/finale will act upon <t> target.
 
wsall:  All jobs will execute preset weaponskill.
 
cc:  Jobs that can sleep with sleep <t> target.
 
zerg:  Toggles zergmode flag, requires custom code in Selindrile's GS
 
wstype: Changes wstype for certain jobs.  ie: piercing will switch SAM to polearm.
 
buffup:  Certain jobs will  do full buffup, requires Selindrile's GS
 
dd: Jobs that can use, will cast dia2/3 or tenebral crush on <t> target.
 
attackon: Jobs are specified with engage current <t> target.
 
buffall: Buff all chars in party with a specific spell. Requires healbot.
 
as:  Assist current char:  ON - Only target lockon, Melee - Melee jobs will engage/attack, MAG - Include BRD, ALL: Every char will melee/engage.  OFF: Every char stop engage/target lockon.
 
smn:  Custom code for SMN autoBP/SC.  Requires custom code and Selindrile's GS.
 
rngsc:  Custom RNGSC code, requires custom code.
 
gt:  Get target with settarget addon.
 
#### Job Related ####

 brd: Functions related to custom BRD code with healbot/Selindrile's GS
 
sch: Functions related to custom SCH code with Selindrile's GS
 
smnburn:  Execute SMN AF/AC burn code, used in conjunction "burn" settings
 
geoburn:  Execute GEO bolster for zerging.  Used in conjunction "burn" settings
 
burn: Configure AF/AC/GEO Burn
 
rng: Toggle Selindrile's smnhelper upon using //mc on
 
proc: Custom toggle for BLM/SCH/GEO proc/MB/autonuke casting sets (mostly vagary)
 
crit: Custome toggle for crit ranged mode for Selindrile's GS

#### Travel Related ####
fon:  All chars in range to follow current char.  Ignores out of range or out of zone. Uses healbot
 
foff:  All chars to stop following.  Ignores out of range or out of zone. Uses healbot
 
mnt:  Mount all chars with specific mount
 
dis:  Dismount all chars
 
warp:  Warp all chars, disabled in town.  Requires myhome
 
omen:  Warp everyone to omen using dimensional ring, requires myomen
 
enup: Uses setkey UP + enter for certain zone portals which activate when  walking over them (Ru'Aun gardens for example)
 
endown: Uses setkey DOWN + enter for certain zone portals which activate when  walking over them.
 
ent: Uses seykey ENTER
 
go: Find nearest NPC and clicks Enter.
 
enter:  Enter various portals/entrances using poke + setkey sequences.  Requires fastcs
 
on:  Toggles all addons that are defined under ON function such as healbot/autogeo/roller/singer etc.
 
get:  Get certain KI's from different NPC's, using poke + setkey sequences.
 
d2: Warp everyone in party using warp II from current char.
 
#### Misc #### 
reload: Reloads a certain addon specified
 
unload: Unloads a certain addon specified
 
fps:  Changes FPS rate, requires config
 
lotall:  Lot all using treasury on all chars
 
cleanstones:  Clean REMA stones from sack>inventory>sack
 
drop:  Drop rem or salvage cells
 
buyalltemps:  Requires Escha addon, buy all temp items in escha.
 
book:  Trade assault book to rune exit.
 
ein:  Enter einherjar or exit einherjar after manually trading lamps.
 
buy:  Buy sparks/acc, requires sparks and powder addons.
 
rand: Randomize char positions
 
send: Send all chars with delay (like send addon)

# Burn

This section is designed for AFAC burns. There are several steps. They can be entered from a single player instance to control all.

1. `mc burn on` starts the process and presents an on screen HUD

      ![image](https://user-images.githubusercontent.com/8727407/151236727-9b78bf86-acab-47d0-8271-f2efcc258bf0.png)

2. You need to set a few things before moving forward. You can either pre-set these settings in the multictrl.lua file defaults or via console commands. Some may be preset
     * `mc burn assist #CHARNAME#` should be set on your tank. This allows all characters to lock onto the tank's target
     * `mc burn avatar #AVATAR#` should be set as needed for your target. Default is Ramuh. Ifrit is supported, as is Siren.
     * `mc burn dia #ON/OFF#` should be set as needed for your target. Default is on. You may wish to not use Dia on someone like Vinipata
     * `mc burn indi #spell#` should be set as needed for your target. Default is refresh. But if you wish to use something like Torpor or Malaise, you can.
3. `mc burn init` will begin the prepatory process, based on the settings chosen.
    * All jobs except COR/WHM/RDM/RUN/THF/SCH: Reloads healbot, disables cure and -na, sets assist as denoted, enables healbot.
    * SMN: Summons chosen Avatar and sets Selindrile Avatar setting to said avatar.
    * COR: Sets Roller to use Beast Roll and Drachen Roll. If Indi-Malaise was set, rolls Beast and Puppet Rolls.
    * GEO: Sets Selindrile Autogeo to Frailty, and Autoindi to chosen Indicolure.
    * RUN: Disables Selindrile Autobuff mode, disables any follow commands, sets Selindrile autorune element to Tenebrae (or Ignis if using Indi-Malaise)
    * THF: Disables curing and -na, sets the assist target and a follow distance of 1.5 on the assist target (this is for Larceny strats)
4. At this point, you can buff up and prepare for the fight, and pop the NM. 
    * You **must** target and engage the NM to make assist work.
    * One way of feeling like you are "safe" to move forward is when you see the other characters lock onto the NM.
5. `mc geoburn` will disable Selindrile autogeo controls and take manual control and do the following:
    * Temporarily disables autogeo/indi functionality and healbot curing and -na.
    * Bolsters
    * Casts Geo-Frailty on target NM, as determined by the assist setting
    * Casts the appropriate Indocolure spell
    * Uses the Dematerialize JA
    * Queues up Dia II to be used by healbot
    * Enables autogeo/indi functionality as well as healbot curing and -na. 
 6. `mc smnburn` is usually almost immediately performed after geoburn has started and will perform the following:
    * Enables healbot
    * Enables Astral Flow
    * Engages Assault on target NM, as determined by the assist setting.
    * Waits 4 seconds for the Avatars to reach the target NM (assuming you were 20' away from the NM, this covers the travel time)
    * Executes the Avatar's moveset as defined by the required scripted text files. There are Vorseal and non-Vorseal versions, but they are the same.
    * Ramuh: Voltstrike.txt
    * Ifrit: FlamingCrush.txt
    * Siren: HystericAssault.txt
    * The scripts use Apogee at the end. This should allow for 18-20 BPs to go off. 
    * The scripts will try to use Apogee again at the very end, if you happen to Wild Card/Random Deal'd.
 7. At the end of this process, either you've beaten the NM using AFAC, or you are dead or soon to be. Good Luck!
