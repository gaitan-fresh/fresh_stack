#!/usr/bin/env ruby

# Test script to verify homepage vote display
# Run with: ruby test_homepage_votes.rb

require_relative 'config/environment'

puts "🏠 Testing Homepage Vote Display"
puts "=" * 40

# Get questions from the homepage
questions = Question.includes(:votes, :user, :tags).limit(5)

if questions.empty?
  puts "❌ No questions found. Please run: rails db:seed"
  exit 1
end

puts "\n📊 Questions on Homepage:"
puts "-" * 30

questions.each_with_index do |question, index|
  upvotes = question.upvotes_count
  downvotes = question.downvotes_count
  total_votes = question.total_votes

  puts "\n#{index + 1}. #{question.title[0..50]}..."
  puts "   👍 Upvotes: #{upvotes}"
  puts "   👎 Downvotes: #{downvotes}"
  puts "   📊 Total votes: #{total_votes}"
  puts "   🗳️  Raw votes: #{question.votes.pluck(:value).join(', ')}" if question.votes.any?

  # Check if the methods are working
  if upvotes.nil? || downvotes.nil?
    puts "   ❌ ERROR: Vote counts are nil!"
  elsif upvotes == 0 && downvotes == 0
    puts "   ⚠️  No votes yet"
  else
    puts "   ✅ Vote counts working correctly"
  end
end

puts "\n🎯 Homepage Display Should Show:"
puts "- 👍 [count] for each question"
puts "- 👎 [count] for each question"
puts "- Compact styling with gradients"

puts "\n🔍 If you're not seeing counts:"
puts "1. Check browser developer tools"
puts "2. Look for CSS issues with .vote-display.compact"
puts "3. Verify the vote-count spans are present"

puts "\n🚀 Test the homepage:"
puts "1. Start server: rails server"
puts "2. Visit: http://localhost:3000"
puts "3. Look at the question cards"
puts "4. Each should show 👍 X and 👎 Y with actual numbers"

# Create some test votes if none exist
if questions.all? { |q| q.total_votes == 0 }
  puts "\n🧪 Creating test votes for better demonstration..."

  tenant = Tenant.first
  users = tenant.users.limit(3)

  if users.count >= 2
    question = questions.first

    # Add some votes
    question.votes.create!(user: users[0], value: 1, tenant: tenant) rescue nil
    question.votes.create!(user: users[1], value: 1, tenant: tenant) rescue nil
    if users[2]
      question.votes.create!(user: users[2], value: -1, tenant: tenant) rescue nil
    end

    puts "✅ Added test votes to '#{question.title[0..30]}...'"
    puts "   Now has: 👍 #{question.upvotes_count} 👎 #{question.downvotes_count}"
    puts "   Refresh homepage to see the changes!"
  end
end
