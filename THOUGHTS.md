variables:

- sleep: (0-24 hours)
- sleep quality: (0-10)
- drugs:
  - caffeine: (0+ cups)
  - alcohol: (0+ drinks)
- happiness: (0-10)
- sex: (yes/no) or (number of times) or (0-24th hour)

variable:
  - id: "sleep"
  - name: "Sleep"
  - type: "number"
  - units: "hours"
  - min: 0
  - max: 24

record:
  - type: "sleep" (references variable table)
  - value: 8.5
  - time: (timestamp)

storage options:
  - CSVs (one file per variable)
  - SQLite

behaviors/tasks:

- create a new variable
- add a new record
- view chart

- add bar chart and calendar view
- store data in json file instead of sqlite 
