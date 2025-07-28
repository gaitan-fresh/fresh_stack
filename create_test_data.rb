#!/usr/bin/env ruby

# Simple script to create test data for Fresh Stack
puts "Creating test data for Fresh Stack..."

# Create tenants
tenant1 = Tenant.create!(name: "TechCorp")
puts "Created tenant: #{tenant1.name}"

# Create admin user
admin = User.create!(
  name: "Admin User",
  email: "admin@techcorp.com",
  password: "password123",
  password_confirmation: "password123",
  role: "admin",
  tenant: tenant1
)
puts "Created admin user: #{admin.email}"

# Create viewer user
viewer = User.create!(
  name: "Viewer User",
  email: "viewer@techcorp.com",
  password: "password123",
  password_confirmation: "password123",
  role: "viewer",
  tenant: tenant1
)
puts "Created viewer user: #{viewer.email}"

# Create tags
ruby_tag = Tag.create!(name: "ruby", tenant: tenant1)
rails_tag = Tag.create!(name: "rails", tenant: tenant1)
js_tag = Tag.create!(name: "javascript", tenant: tenant1)
puts "Created tags: ruby, rails, javascript"

# Create a question
question = Question.create!(
  title: "How to get started with Rails?",
  body: "I'm new to Ruby on Rails and want to learn the basics. What are the best resources and practices for beginners?",
  user: admin,
  tenant: tenant1
)
question.tags << [ ruby_tag, rails_tag ]
puts "Created question: #{question.title}"

# Create a response
response = Response.create!(
  body: "I recommend starting with the official Rails guides at guides.rubyonrails.org. They provide comprehensive tutorials for beginners.",
  user: viewer,
  parent: question,
  tenant: tenant1
)
puts "Created response to question"

# Create a blog post
blog = Blog.create!(
  title: "Getting Started with Ruby on Rails",
  body: "Ruby on Rails is a powerful web framework that makes it easy to build web applications quickly. In this post, we'll explore the fundamentals of Rails and how to get started with your first application.",
  user: admin,
  tenant: tenant1
)
blog.tags << [ ruby_tag, rails_tag ]
blog.questions << [ question ]
puts "Created blog post: #{blog.title}"

puts "\nTest data created successfully!"
puts "You can now login with:"
puts "Admin: admin@techcorp.com / password123"
puts "Viewer: viewer@techcorp.com / password123"
