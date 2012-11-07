# Universal Combat Log Format

Glossary:

* short: 2 byte unsigned integer.
* int: 4 byte unsigned integer.
* long: 8 byte unsogned integer.
* UTF-8: Unicode string encoded as UTF-8.
* "ABCD": 4 byte sequence of ASCII characters.

## File Type Marker

* "UCL1"

## Entity Index

* "ENT1" : section marker
* int : number of entities

### Entity

Repeated for the number of entities described above.

* long : entity id
* byte : entity kind -- 'P' = player, 'N' = non-player
* byte : entity relationship -- 'C' = recorder, 'G' = group, 'R' = raid, 'O' = other
* long : entity owner id
* short : entity name length in bytes
* UTF-8 : entity name

## Spell Index

* "SPL1" : section marker
* int : number of spells

### Spell

Repeated for the number of spells described above.

* long : spell id
* short : spell name length in bytes
* UTF-8 : spell name

## Fights

* "FIT1" : section marker
* int : number of fights

### Fight

Repeated for the number of fights described above, including the list of events described below.

* short : fight title in bytes
* UTF-8 : fight title
* int : number of events

#### Event

Repeated for the number of events described above, per fight.

* long : Unix timestamp
* byte : event type
* long : actor ID
* long : target ID
* long : spell ID
* long : amount
* short : text length in byes
* UTF-8 : text
