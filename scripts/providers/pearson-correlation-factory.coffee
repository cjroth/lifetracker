angular
  .module 'lifetracker'
  .factory 'pearsonCorrelation', ->

    # borrowed from https://gist.github.com/matt-west/6500993
    return (prefs, p1, p2) ->

      si = []

      for key of prefs[p1]
        si.push key if prefs[p2][key]
      n = si.length

      return 0 if n is 0

      sum1 = 0
      i = 0

      while i < si.length
        sum1 += prefs[p1][si[i]]
        i++

      sum2 = 0
      i = 0

      while i < si.length
        sum2 += prefs[p2][si[i]]
        i++
        
      sum1Sq = 0
      i = 0

      while i < si.length
        sum1Sq += Math.pow(prefs[p1][si[i]], 2)
        i++
      sum2Sq = 0
      i = 0

      while i < si.length
        sum2Sq += Math.pow(prefs[p2][si[i]], 2)
        i++
      pSum = 0
      i = 0

      while i < si.length
        pSum += prefs[p1][si[i]] * prefs[p2][si[i]]
        i++
      num = pSum - (sum1 * sum2 / n)
      den = Math.sqrt((sum1Sq - Math.pow(sum1, 2) / n) * (sum2Sq - Math.pow(sum2, 2) / n))
      return 0 if den is 0
      return num / den
