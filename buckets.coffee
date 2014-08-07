NICE_INTERVALS = [1, 1.2, 1.5, 1.6, 2, 2.5, 3, 5, 8]


buckets = (stops, range) ->
  [lowest, highest] = range
  smallest = (highest - lowest) / stops
  magnitude = 10 ** Math.floor ((Math.log smallest) / Math.log 10)

  for interval in NICE_INTERVALS
    bucket = interval * magnitude
    if bucket < smallest
      continue
    min = bucket * (lowest // bucket)
    max = min + (bucket * stops)
    if max >= highest
      break

  return ((do (m=min+n*bucket) -> [m, m+bucket]) for n in [0..stops-1])


# export tricks borrowed from husl:
# github.com/boronine/husl/blob/d31224c26cf30f0f956a7e3d5d22590ec63a958d/husl.coffee#L306

# If no framework is available, just export to the global object (window.HUSL
# in the browser)
@buckets = buckets unless module? or requirejs?
# Export to Node.js
module.exports = buckets if module?
# Export to RequireJS
define(buckets) if requirejs? and define?
