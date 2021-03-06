# Universal Combat Log

Universal Combat Log is an iOS 5.1 iPad app for viewing MMORPG combat logs. Logs are broken down into fights, which can be view individually. For a particular fight, an overview of the fight is shown and you can drill down to get more detailed information about individual players.

The app uses a binary format (.ucl files) for compactness and speed of loading. Text logs from games like Rift and WoW have to be converted to UCL files before they can be viewed in the app. The [Universal Combat Log Desktop](https://github.com/doxxx/universal-combat-log-desktop) app can be used to convert Rift and WoW text combat logs to UCL files.

Log files can be made available to the UCL app in various ways:

1. Copying the UCL file into the app's documents folder by dragging it into iTunes when your device is connected.
1. Opening a text log file in the UCL Desktop app, which automatically makes the log available to the UCL app in the Network Servers list.

## Building

Building the app requires XCode 4.5 and [SBJson 3.1.1](http://github.com/stig/json-framework). The SBJson 3.1.1 distribution is already included in the repo and linked into the XCode project as a dependency.
