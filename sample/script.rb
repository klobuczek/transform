Transform::Dsl.draw do
  define_collection :a, :a, :b, :c
  calculate(:b, :a, :sum) { |a| a.a.to_i + a.b.to_i + a.c.to_i }
  compose(:c, :a, :b)
  slice :d, :c, :a, :sum
  filter(:e, :d) {|d| d.sum.to_i > 6}
  aggregate(:f, :e, 0, :total) {|total, e| total + e.sum.to_i}
  store :f
end
