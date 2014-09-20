angular
  .module 'lifetracker'
  .directive 'numbersOnly', ->
    return {
      require: 'ngModel'
      link: (scope, element, attrs, modelCtrl) ->
        modelCtrl.$parsers.push (inputValue) ->
           if inputValue is undefined then return ''
           transformedInput = inputValue.replace(/[^-.0-9]/g, '')
           if transformedInput != inputValue
              modelCtrl.$setViewValue(transformedInput)
              modelCtrl.$render()
           return transformedInput
    }