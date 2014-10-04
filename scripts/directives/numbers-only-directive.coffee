angular
  .module 'lifetracker'
  .directive 'numbersOnly', ->
    return {
      require: 'ngModel'
      link: (scope, element, attrs, modelController) ->
        modelController.$parsers.push (inputValue) ->
           if inputValue is undefined then return ''
           transformedInput = inputValue.replace(/[^-.0-9]/g, '')
           if transformedInput != inputValue
              modelController.$setViewValue(transformedInput)
              modelController.$render()
           return transformedInput
    }