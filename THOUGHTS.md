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

new data model:

- limit to one record per variable per day
- create unique index in records table across variable_id and timestamp
- change timestamp to date (2014-09-08)
- editing a value will open the wizard with all values from that day, but to the step for that variable
- editing and creating data wizard should be a large modal
- records will be evenly spaced on chart because they will be aligned to each date
- when add data button is clicked, it will check if there is already data for today
  - if there is, it will go to the wizard to edit it
  - if there is not, it will go to the wizard with a new entry
- wizard should have a datepicker. if we change the date, it should fill in the data from that date for editing.

these changes will enable a new view. in addition to charts, we can show a calendar view. the calendar can show one
variable at a time. each day on the calendar will be shaded between white and dark. the darker the day is shaded,
the higher the value for that variable for that day.