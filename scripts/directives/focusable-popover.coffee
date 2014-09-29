angular
  .module('lifetracker')
  .directive 'focusablePopover', ($timeout) ->
    return (
      restrict: 'EAC'
      link: (scope, element, attrs) ->
        $body = angular.element('body')
        _hide = ->
          if scope.$hide
            scope.$hide()
            scope.$apply()
          return
        
        # Stop propagation when clicking inside popover.
        $timeout (->
          element.on 'click', (event) ->
            event.stopPropagation()
            return

          
          # Hide when clicking outside.
          $body.one 'click', _hide
          
          # Safe remove.
          scope.$on '$destroy', ->
            $body.off 'click', _hide
            element.off 'click'
            return

          return
        ), 0
        return
    )