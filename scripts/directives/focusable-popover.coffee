# angular.module('lifetracker')
# .directive "focusablePopover", [
#   "$timeout"
#   ($timeout) ->
#     return (
#       restrict: "EAC"
#       link: (scope, element, attrs) ->
#         console.log 'why no work'
#         _hide = ->
#           console.log 'blehahdgasdgadsg', scope, element

#           if scope.$hide?
#             scope.$hide()
#             scope.$apply()
#             return
#           if scope.$$childHead.$hide?
#             scope.$$childHead.$hide()
#             scope.$$childHead.$apply()
#             return

        
#         # Stop propagation when clicking inside popover.
#         element.on "click", (event) ->
#           console.log 'clicked on element'
#           event.stopPropagation()
#           return

        
#         # Hide when clicking outside.
#         $timeout (->
#           angular.element("body").on "click", _hide
#           return
#         ), 0
        
#         # Safe remove.
#         scope.$on "$destroy", ->
#           angular.element("body").off "click", _hide
#           return

#         return
#     )
# ]

angular
  .module("lifetracker")
  .directive "focusablePopover", ($timeout) ->
    return (
      restrict: "EAC"
      link: (scope, element, attrs) ->
        $body = angular.element("body")
        _hide = ->
          if scope.$hide
            scope.$hide()
            scope.$apply()
          return
        
        # Stop propagation when clicking inside popover.
        $timeout (->
          element.on "click", (event) ->
            event.stopPropagation()
            return

          
          # Hide when clicking outside.
          $body.one "click", _hide
          
          # Safe remove.
          scope.$on "$destroy", ->
            $body.off "click", _hide
            element.off "click"
            return

          return
        ), 0
        return
    )