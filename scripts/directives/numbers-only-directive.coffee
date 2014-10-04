angular
  .module 'lifetracker'
  .directive 'numbersOnly', ->
    return {
      require: 'ngModel'
      link: (scope, element, attrs, modelController) ->
        modelController.$parsers.push (value) ->
           number = parseFloat(value)
           if _.isNaN(number) then number = null
           transformedInput = if number? then String(number) else ''
           if transformedInput isnt value
              modelController.$setViewValue(transformedInput)
              modelController.$render()
           return number
    }