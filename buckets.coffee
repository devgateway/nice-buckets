
magic = (stops, range, intervals) ->
  intervals ?= [1, 1.2, 1.5, 1.6, 2, 2.5, 3, 5, 8]
  [lowest, highest] = range
  smallest = (highest - lowest) / stops
  if smallest == 0
    return [range]
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

  # skip out of there is no range
  if bucket == 0
    return [range]

  # lowest power of base we round to
  precision = Infinity

  # find number in [n - k, n] which has minimal sig figs
  nicify = (n, k) ->
    # next lowest power of base to k
    p = base ** Math.floor ( (Math.log k) / Math.log base )
    # next highest power of base to k
    q = base * p

    # there are two candidates for least sig figs
    # first,
    min = q * Math.floor ( n / q )
    precision = q if q < precision
    # but this may be outside allowable range
    if min < n - k
      # second, which is guaranteed to be in allowable range
      min = p * Math.floor ( n / p )
      precision = p if p < precision
    return min

  # round lower bound down to within maxOverlap
  # remove most sig figs allowable from lower bound
  lowest = nicify lowest, (maxOut * bucket)

  # ensure entire range is covered
  bucket = (highest - lowest) / stops

  # increase bin size by up to (bucket / stops)
  # removing the most sig figs possible
  bucket = nicify bucket + (bucket / stops), bucket / stops

  # clean up floating point errors
  r = (n) -> Math.round(n / precision) / (1 / precision)

  ((do (m=lowest+bucket*n) -> [r(m), r(m+bucket)]) for n in [0..stops-1])


root =
  magic: magic
  minFigs: minFigs

# export tricks borrowed from husl:
# github.com/boronine/husl/blob/d31224c26cf30f0f956a7e3d5d22590ec63a958d/husl.coffee#L306

# If no framework is available, just export to the global object (window.buckets
# in the browser)
@buckets = root unless module? or requirejs?
# Export to Node.js
module.exports = root if module?
# Export to RequireJS
define(root) if requirejs? and define?
