Transform::Dsl.draw do
  define_collection :a, :c1, :c2, :c3
  calculate(:b, :a, :sum) { |a| a.c1.to_i + a.c2.to_i + a.c3.to_i }
  compose(:c, :a, :b)
  slice :d, :c, :c1, :sum
  filter(:e, :d) {|d| d.sum.to_i > 6}
  aggregate(:f, :e, 0, :total) {|total, e| total + e.sum.to_i}
  store :f
end
