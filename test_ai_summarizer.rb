#!/usr/bin/env ruby

# Test script for AI Summarizer
# Run with: ruby test_ai_summarizer.rb

require_relative 'config/environment'

puts "🧪 Testing AI Summarizer Service..."

# Test with a sample question
tenant = Tenant.first
if tenant.nil?
  puts "❌ No tenant found. Please run: rails db:seed"
  exit 1
end

question = tenant.questions.includes(:responses, :user, :tags).first
if question.nil?
  puts "❌ No questions found. Please run: rails db:seed"
  exit 1
end

puts "📝 Testing with question: '#{question.title}'"
puts "👤 Author: #{question.user.name}"
puts "🏷️  Tags: #{question.tags.pluck(:name).join(', ')}"
puts "💬 Responses: #{question.responses.count}"

begin
  ai_service = AiSummarizerService.new
  puts "\n🤖 Generating AI summary..."

  summary = ai_service.summarize_question(question)

  puts "\n✅ Summary generated successfully!"
  puts "📄 Summary:"
  puts "=" * 50
  puts summary
  puts "=" * 50

rescue => e
  puts "\n❌ Error: #{e.message}"
  puts "🔍 Make sure you have:"
  puts "   1. Added Google Gemini API key to Rails credentials"
  puts "   2. Installed the httparty gem (bundle install)"
  puts "   3. Internet connection"
  puts "   4. Enabled Generative Language API in Google Cloud Console"
end

# Test with a blog if available
blog = tenant.blogs.includes(:user, :tags, :questions).first
if blog
  puts "\n📰 Testing with blog: '#{blog.title}'"

  begin
    summary = ai_service.summarize_blog(blog)
    puts "\n✅ Blog summary generated successfully!"
    puts "📄 Blog Summary:"
    puts "=" * 50
    puts summary
    puts "=" * 50
  rescue => e
    puts "\n❌ Blog summary error: #{e.message}"
  end
end

puts "\n🎉 Test completed!"
