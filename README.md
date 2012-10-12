# Universal Combat Log

Universal Combat Log is an iPad app for viewing MMORPG combat logs. Logs are broken down into fights and fights are broken down by player. Various data about the player's performance in the fight is shown, including a timeline of the player's DPS for the fight and a breakdown of the spells used and their hit/crit rate and min/max/avg damage.

The app uses a binary format (.ucl files) for compactness and speed of loading. Text logs from games like Rift and WoW have to be converted to UCL files before they can be viewed in the app. The [Universal Combat Log Desktop](http://https://github.com/doxxx/universal-combat-log-desktop) app can be used to convert Rift and WoW text combat logs to UCL files.

Log files can be made available to the UCL app in various ways:

- Copying the UCL file into the app's documents folder by dragging it into iTunes when your device is connected.
- Running the UCL Desktop app, opening a text log file and then connecting to the appropriate 'network server' entry in the UCL app.

## Building

Building the app requires XCode 4.3.
