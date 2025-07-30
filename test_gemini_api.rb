#!/usr/bin/env ruby

# Simple test to verify Gemini API connection
# Run with: ruby test_gemini_api.rb

require_relative 'config/environment'
require 'httparty'

puts "🧪 Testing Google Gemini API Connection..."

# Check if API key exists
api_key = Rails.application.credentials.google_gemini_api_key || ENV['GOOGLE_GEMINI_API_KEY']
if api_key.blank?
  puts "❌ No API key found"
  puts "💡 Option 1 - Environment Variable:"
  puts "   export GOOGLE_GEMINI_API_KEY='your_api_key_here'"
  puts "💡 Option 2 - Rails Credentials:"
  puts "   EDITOR='nano' rails credentials:edit"
  puts "   Add: google_gemini_api_key: your_api_key_here"
  exit 1
end

puts "✅ API key found: #{api_key[0..10]}..."

# Test API connection with simple request
begin
  url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=#{api_key}"

  response = HTTParty.post(
    url,
    headers: {
      'Content-Type' => 'application/json'
    },
    body: {
      contents: [
        {
          parts: [
            {
              text: "Say hello and confirm you're working!"
            }
          ]
        }
      ]
    }.to_json
  )

  if response.success?
    text = response.parsed_response.dig('candidates', 0, 'content', 'parts', 0, 'text')
    puts "✅ API Connection Successful!"
    puts "🤖 Gemini Response: #{text}"
    puts "\n🎉 Your AI summarization feature is ready to use!"
  else
    puts "❌ API Error: #{response.code}"
    puts "📄 Response: #{response.body}"
    puts "\n💡 Troubleshooting:"
    puts "   1. Check your API key is valid"
    puts "   2. Enable Generative Language API in Google Cloud Console"
    puts "   3. Make sure you have internet connection"
  end

rescue => e
  puts "❌ Connection Error: #{e.message}"
  puts "\n💡 Check your internet connection and try again"
end
