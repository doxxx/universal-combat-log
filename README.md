# Universal Combat Log

Universal Combat Log is an iPad app for viewing MMORPG combat logs. Logs are broken down into fights and fights are broken down by player. Various data about the player's performance in the fight is shown, including a timeline of the player's DPS for the fight and a breakdown of the spells used and their hit/crit rate and min/max/avg damage.

The app uses a binary format for compactness and speed of loading. Text logs from games like Rift and WoW have to be converted to this binary format before they can be viewed in the app. A converter tool written in Scala exists for Rift and will be added shortly. I plan to write a converter for WoW as well.

## Building

Building the app requires XCode 4.3.
