var assert = require('assert');
var buckets = require('./buckets');


function testBucketer(name) {
  var b = buckets[name];
  describe('Bucketer ' + name, function() {
    describe('easy cases', function() {
      it('should find buckets that are just equal whole number ranges', function() {
        assert.deepEqual(b(2, [0, 2]), [[0, 1], [1, 2]]);
      });
    });
    describe('regressions', function() {
      it('should not break when range min === range max', function() {
        b(1, [1, 1]).forEach(function(edges) {
          assert.equal.apply(null, edges);
        });
      });
      it('should return unique buckets', function() {
        assert.notEqual(b(2, [1, 1]).length, 2);
      });
    });
  });
}



testBucketer('minFigs');
testBucketer('magic');
