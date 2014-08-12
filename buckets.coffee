
magic = (stops, range, intervals) ->
  intervals ?= [1, 1.2, 1.5, 1.6, 2, 2.5, 3, 5, 8]
  [lowest, highest] = range
  smallest = (highest - lowest) / stops
  magnitude = 10 ** Math.floor ((Math.log smallest) / Math.log 10)

  for interval in intervals
    bucket = interval * magnitude
    if bucket < smallest
      continue
    min = bucket * (lowest // bucket)
    max = min + (bucket * stops)
    if max >= highest
      break

  ((do (m=min+bucket*n) -> [m, m+bucket]) for n in [0..stops-1])


minFigs = (stops, range, maxOut, base) ->
  # algorithm originally by @JamieMacdo
  maxOut ?= 0.99
  base ?= 10
  [lowest, highest] = range

  # simplification 1: limit to maxOut * exact partition size overlap on ends
  bucket = (highest - lowest) / stops
  max_overlap = maxOut * bucket

  # round lower bound down to within max_overlap
  # remove most sig figs allowable from lower bound
  k = base ** Math.floor ( (Math.log max_overlap) / Math.log base ) # next lowest power of base
  min = k * Math.floor lowest / k

  # ensure entire range is covered
  bucket += (lowest - min) / stops
  # increase bin size by up to ((lowest - min) + max_overlap) / stops
  # removing the most sig figs possible
  k = base ** Math.floor ( Math.log max_overlap / stops, base )
  bucket = (Math.ceil bucket / k) * k

  # clean up floating point errors
  r = (n) -> Math.round(n / k) / (1/k)

  ((do (m=min+bucket*n) -> [r(m), r(m+bucket)]) for n in [0..stops-1])


root =
  magic: magic
  minFigs: minFigs

# export tricks borrowed from husl:
# github.com/boronine/husl/blob/d31224c26cf30f0f956a7e3d5d22590ec63a958d/husl.coffee#L306

# If no framework is available, just export to the global object (window.HUSL
# in the browser)
@buckets = root unless module? or requirejs?
# Export to Node.js
module.exports = root if module?
# Export to RequireJS
define(root) if requirejs? and define?
