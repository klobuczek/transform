puts "Dsl required"
Transform::Dsl.draw do
  load_collection :a, 'test.csv', :a, :b, :c
  puts "draw"
end
