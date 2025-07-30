#!/usr/bin/env ruby

# Test script to verify new vote logic
# Run with: ruby test_vote_logic.rb

require_relative 'config/environment'

puts "🧪 Testing New Vote Logic..."

# Get a question with votes
question = Question.joins(:votes).first
if question.nil?
  puts "❌ No questions with votes found. Creating test data..."
  
  # Create test data
  tenant = Tenant.first
  user1 = tenant.users.first
  user2 = tenant.users.second
  
  if user1 && user2
    test_question = tenant.questions.create!(
      title: "Test Question for Vote Logic",
      body: "This is a test question to verify vote counting logic.",
      user: user1
    )
    
    # Add some votes
    test_question.votes.create!(user: user1, value: 1, tenant: tenant)  # Upvote
    test_question.votes.create!(user: user2, value: 1, tenant: tenant)  # Upvote
    
    question = test_question
    puts "✅ Created test question with votes"
  else
    puts "❌ Not enough users found. Please run: rails db:seed"
    exit 1
  end
end

puts "\n📊 Testing Question: '#{question.title}'"
puts "=" * 50

# Test the new vote logic
upvotes = question.upvotes_count
downvotes = question.downvotes_count
vote_score = question.vote_score
net_score = question.net_vote_score

puts "👍 Upvotes: #{upvotes}"
puts "👎 Downvotes: #{downvotes}"
puts "📊 Vote Score (max): #{vote_score}"
puts "🧮 Net Score (sum): #{net_score}"

puts "\n🔍 Logic Verification:"
expected_max = [upvotes, downvotes].max
if vote_score == expected_max
  puts "✅ Vote score logic is correct!"
  puts "   Showing: #{vote_score} (#{upvotes >= downvotes ? 'upvotes' : 'downvotes'})"
else
  puts "❌ Vote score logic is incorrect!"
  puts "   Expected: #{expected_max}, Got: #{vote_score}"
end

# Test with responses if available
response = question.responses.joins(:votes).first
if response
  puts "\n📝 Testing Response Votes:"
  puts "👍 Response Upvotes: #{response.upvotes_count}"
  puts "👎 Response Downvotes: #{response.downvotes_count}"
  puts "📊 Response Vote Score: #{response.vote_score}"
end

puts "\n🎯 Summary:"
puts "- Old logic: Sum of all votes (net score)"
puts "- New logic: Maximum of upvotes or downvotes"
puts "- UI shows: The higher count with appropriate emoji"

puts "\n🚀 Test your changes:"
puts "1. Start server: rails server"
puts "2. Visit: http://localhost:3000"
puts "3. Look for vote counts with 👍/👎 indicators"