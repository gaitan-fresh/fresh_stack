#!/usr/bin/env ruby

# Test script to verify Rails setup without API calls
# Run with: ruby test_setup.rb

require_relative 'config/environment'

puts "🧪 Testing Fresh Stack Setup..."

# Test database connection
begin
  ActiveRecord::Base.connection
  puts "✅ Database connection: OK"
rescue => e
  puts "❌ Database connection failed: #{e.message}"
  exit 1
end

# Test models
begin
  tenant_count = Tenant.count
  user_count = User.count
  question_count = Question.count
  blog_count = Blog.count

  puts "✅ Models working: OK"
  puts "   📊 Tenants: #{tenant_count}"
  puts "   👥 Users: #{user_count}"
  puts "   ❓ Questions: #{question_count}"
  puts "   📝 Blogs: #{blog_count}"
rescue => e
  puts "❌ Models failed: #{e.message}"
  exit 1
end

# Test AI service class (without API call)
begin
  # This will fail if no API key, but we can catch it
  ai_service = AiSummarizerService.new
  puts "✅ AI Service class: OK (API key found)"
rescue => e
  if e.message.include?("API key not found")
    puts "⚠️  AI Service: API key not set (expected)"
    puts "   💡 Set API key to enable AI features"
  else
    puts "❌ AI Service failed: #{e.message}"
  end
end

# Test routes
begin
  Rails.application.routes.url_helpers.questions_path
  Rails.application.routes.url_helpers.blogs_path
  puts "✅ Routes: OK"
rescue => e
  puts "❌ Routes failed: #{e.message}"
end

puts ""
puts "🎯 Setup Status:"
if tenant_count > 0 && user_count > 0
  puts "✅ Ready to test! You have data to work with."
  puts "💡 Start server: rails server"
  puts "💡 Visit: http://localhost:3000"
else
  puts "⚠️  No data found. Run: rails db:seed"
end

puts ""
puts "🤖 AI Feature Status:"
api_key = Rails.application.credentials.google_gemini_api_key || ENV['GOOGLE_GEMINI_API_KEY']
if api_key.present?
  puts "✅ API key configured"
  puts "💡 Test AI: ruby test_gemini_api.rb"
else
  puts "⚠️  API key not set"
  puts "💡 Quick setup: export GOOGLE_GEMINI_API_KEY='your_key_here'"
  puts "💡 Get key from: https://aistudio.google.com/app/apikey"
end

puts ""
puts "🎉 Fresh Stack is ready!"
