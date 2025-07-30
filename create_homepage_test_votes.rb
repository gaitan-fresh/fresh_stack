#!/usr/bin/env ruby

# Create test votes for homepage demonstration
# Run with: ruby create_homepage_test_votes.rb

require_relative 'config/environment'

puts "🗳️  Creating Test Votes for Homepage"
puts "=" * 40

tenant = Tenant.first
users = tenant.users.limit(5)
questions = tenant.questions.limit(5)

if users.count < 3
  puts "❌ Need at least 3 users. Please run: rails db:seed"
  exit 1
end

if questions.count < 3
  puts "❌ Need at least 3 questions. Please run: rails db:seed"
  exit 1
end

puts "✅ Found #{users.count} users and #{questions.count} questions"

# Clear existing votes to start fresh
Vote.destroy_all
puts "🧹 Cleared existing votes"

# Create varied voting patterns
vote_patterns = [
  { up: 5, down: 1, desc: "Popular question" },
  { up: 2, down: 7, desc: "Controversial question" },
  { up: 8, down: 0, desc: "Highly upvoted question" },
  { up: 0, down: 3, desc: "Downvoted question" },
  { up: 0, down: 0, desc: "No votes question" }
]

questions.each_with_index do |question, index|
  pattern = vote_patterns[index] || { up: 0, down: 0, desc: "No votes" }

  puts "\n#{index + 1}. #{question.title[0..40]}..."
  puts "   Creating: #{pattern[:up]} upvotes, #{pattern[:down]} downvotes (#{pattern[:desc]})"

  # Create upvotes
  pattern[:up].times do |i|
    user = users[i % users.count]
    begin
      question.votes.create!(user: user, value: 1, tenant: tenant)
    rescue ActiveRecord::RecordInvalid => e
      puts "   ⚠️  Skipped duplicate vote for user #{user.name}"
    end
  end

  # Create downvotes (use different users)
  pattern[:down].times do |i|
    user_index = (pattern[:up] + i) % users.count
    user = users[user_index]
    begin
      question.votes.create!(user: user, value: -1, tenant: tenant)
    rescue ActiveRecord::RecordInvalid => e
      puts "   ⚠️  Skipped duplicate vote for user #{user.name}"
    end
  end

  # Verify the counts
  actual_up = question.upvotes_count
  actual_down = question.downvotes_count
  puts "   ✅ Result: 👍 #{actual_up} 👎 #{actual_down}"
end

puts "\n📊 Final Homepage Vote Summary:"
puts "-" * 30

questions.reload.each_with_index do |question, index|
  puts "#{index + 1}. #{question.title[0..30]}..."
  puts "   👍 #{question.upvotes_count} 👎 #{question.downvotes_count}"
end

puts "\n🎯 What You Should See on Homepage:"
puts "- Each question card should show colorful vote buttons"
puts "- 👍 [number] and 👎 [number] with actual counts"
puts "- Green gradient for upvotes, red for downvotes"
puts "- Gray/dimmed styling for zero votes"

puts "\n🚀 Test the homepage now:"
puts "1. Start server: rails server"
puts "2. Visit: http://localhost:3000"
puts "3. Look for the vote displays on each question card"
puts "4. You should see varied vote counts now!"

puts "\n🔍 If you still don't see counts:"
puts "1. Hard refresh the page (Cmd+Shift+R or Ctrl+Shift+R)"
puts "2. Check browser developer tools for CSS issues"
puts "3. Look for the .vote-count spans in the HTML"
puts "4. The debug CSS should show borders around the counts"
