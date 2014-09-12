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

bar chart:
two possibilties to get this working:
  a) only allow bar chart for one variable at a time, kind of like calendar
  b) omit dates that do not have data for all selected variables

compare:
screen to compare any two variables, with one on the x-axis and one on the y-axis. there should be a button
in the corner to switch the axes (x and y axes switch). this would really only make sense as a scatterplot.
and it should show the correlation coefficient somewhere. (eg 100% positively correlated or 50% negatively
correlated). this would be easy to do with d3. and here's a super out-there idea: what if we found a 3d
library and could do 3-way correlation?

correlation suggestion screen:
a suggestion (this might just be a modal... or even just a notification?) to notify the user that we found
correlations between different variables. it would basically just iterate through each combination of two
variables calculating correlations. then if the coefficient for any two variables is notable it would show the
user a little notification. when the user clicks the notfication, a modal could pop up to explain what
this all means. then there would be a button for each correlation to go to the scatterplot of those
two variables.

variable database/suggestions:
an online database of variables that users have created. when you go to create a new variable, it would
autocomplete or recommend variables from this database. they would have to be sorted/curated for quality
and merged (eg Sleep should be the same as sleeep). the lift app does this well.

pooled stats:
once different users are using the same variable, we could allow user to anonymously send data to server
and then get mass data. this could be really cool for science!

themes:
it would be interesting to have "themes" of related variables. for example, a therapist could recommend
a physical therapy theme for their clients. a psychologist could recommend a sleep theme. etc.

desktop entry and reminders:
kind of like day one, allow user to input data from the system tray, without even opening the app.
reminders would be growl reminders perhaps. user could set a specific time for them.

social:
compare data with friends or let friends be accountability partners with each other.