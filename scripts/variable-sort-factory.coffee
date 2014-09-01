angular
  .module 'lifetracker'
  .factory 'variableSorter', ->
      return (a, b) -> a.name?.toLowerCase() > b.name?.toLowerCase()