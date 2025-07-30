#!/usr/bin/env ruby

# Demonstrate the new vote logic with examples
# Run with: ruby demo_vote_logic.rb

require_relative 'config/environment'

puts "🎯 Vote Logic Demonstration"
puts "=" * 40

puts "\n📊 How the New Logic Works:"
puts "- OLD: Show net score (upvotes - downvotes)"
puts "- NEW: Show maximum count (higher of upvotes or downvotes)"

puts "\n🧮 Examples:"

examples = [
  { up: 5, down: 2, description: "Popular post" },
  { up: 1, down: 8, description: "Controversial/unpopular post" },
  { up: 3, down: 3, description: "Balanced post" },
  { up: 0, down: 1, description: "Single downvote" },
  { up: 10, down: 0, description: "Only upvotes" }
]

examples.each_with_index do |example, index|
  up = example[:up]
  down = example[:down]
  old_score = up - down  # Net score
  new_score = [ up, down ].max  # Max count
  winner = up >= down ? "👍 upvotes" : "👎 downvotes"

  puts "\n#{index + 1}. #{example[:description]}:"
  puts "   Votes: #{up} 👍, #{down} 👎"
  puts "   OLD display: #{old_score}"
  puts "   NEW display: #{new_score} (#{winner})"
end

puts "\n🎨 UI Changes:"
puts "- Vote count now shows with 👍 or 👎 emoji"
puts "- Indicates whether upvotes or downvotes are higher"
puts "- Green color for upvotes, red for downvotes"

# Test with actual data
question = Question.joins(:votes).first
if question
  puts "\n🧪 Real Data Test:"
  puts "Question: '#{question.title}'"
  puts "👍 Upvotes: #{question.upvotes_count}"
  puts "👎 Downvotes: #{question.downvotes_count}"
  puts "Display: #{question.vote_score} #{question.upvotes_count >= question.downvotes_count ? '👍' : '👎'}"
end

puts "\n✅ Changes Applied To:"
puts "- Questions index page"
puts "- Question detail page"
puts "- Response voting"
puts "- User profile page"
puts "- Blog related questions"
puts "- AI summarization service"

puts "\n🚀 Start your server to see the changes!"
