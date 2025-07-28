# Create tenants
puts "Creating tenants..."
tenant1 = Tenant.create!(name: "TechCorp")
tenant2 = Tenant.create!(name: "StartupHub")

puts "Created #{Tenant.count} tenants"

# Create users for TechCorp
puts "Creating users..."
admin_user = User.create!(
  name: "Alice Admin",
  email: "alice@techcorp.com",
  password: "password123",
  password_confirmation: "password123",
  role: "admin",
  tenant: tenant1
)

viewer_user = User.create!(
  name: "Bob Viewer",
  email: "bob@techcorp.com",
  password: "password123",
  password_confirmation: "password123",
  role: "viewer",
  tenant: tenant1
)

# Create users for StartupHub
startup_admin = User.create!(
  name: "Diana Admin",
  email: "diana@startuphub.com",
  password: "password123",
  password_confirmation: "password123",
  role: "admin",
  tenant: tenant2
)

puts "Created #{User.count} users"

# Create tags for TechCorp
ApplicationRecord.with_tenant(tenant1) do
  ruby_tag = Tag.create!(name: "ruby", tenant: tenant1)
  rails_tag = Tag.create!(name: "rails", tenant: tenant1)
  javascript_tag = Tag.create!(name: "javascript", tenant: tenant1)
  database_tag = Tag.create!(name: "database", tenant: tenant1)
  api_tag = Tag.create!(name: "api", tenant: tenant1)

  puts "Created #{Tag.count} tags for TechCorp"

  # Create questions for TechCorp
  question1 = Question.create!(
    title: "How to implement authentication in Rails?",
    body: "I'm building a Rails application and need to implement user authentication. What are the best practices and gems to use?",
    user: admin_user,
    tenant: tenant1
  )
  question1.tags << [ ruby_tag, rails_tag ]

  question2 = Question.create!(
    title: "Database optimization techniques",
    body: "What are some effective techniques for optimizing database queries in a Rails application with large datasets?",
    user: admin_user,
    tenant: tenant1
  )
  question2.tags << [ rails_tag, database_tag ]

  question3 = Question.create!(
    title: "JavaScript async/await best practices",
    body: "I'm working with async/await in JavaScript and want to know the best practices for error handling and performance.",
    user: admin_user,
    tenant: tenant1
  )
  question3.tags << [ javascript_tag ]

  puts "Created #{Question.count} questions for TechCorp"

  # Create responses
  response1 = Response.create!(
    body: "For Rails authentication, I recommend using Devise gem. It's well-maintained and provides comprehensive authentication features including registration, login, password reset, and more.",
    user: viewer_user,
    parent: question1,
    tenant: tenant1
  )

  response2 = Response.create!(
    body: "You can also consider building custom authentication using has_secure_password if you want more control over the authentication flow.",
    user: admin_user,
    parent: question1,
    tenant: tenant1
  )

  # Accept the first response
  response1.update!(is_accepted: true)

  response3 = Response.create!(
    body: "For database optimization, consider using database indexes, eager loading with includes(), and query optimization techniques like select() to limit columns.",
    user: viewer_user,
    parent: question2,
    tenant: tenant1
  )

  # Create nested response
  nested_response = Response.create!(
    body: "Great point about eager loading! Also consider using counter_cache for frequently accessed counts.",
    user: admin_user,
    parent: response3,
    tenant: tenant1
  )

  puts "Created #{Response.count} responses for TechCorp"

  # Create votes
  Vote.create!(value: 1, user: viewer_user, question: question1, tenant: tenant1)
  Vote.create!(value: 1, user: admin_user, question: question2, tenant: tenant1)
  Vote.create!(value: 1, user: viewer_user, response: response1, tenant: tenant1)
  Vote.create!(value: -1, user: admin_user, response: response2, tenant: tenant1)

  puts "Created #{Vote.count} votes for TechCorp"

  # Create blogs
  blog1 = Blog.create!(
    title: "Getting Started with Ruby on Rails",
    body: "Ruby on Rails is a powerful web application framework that follows the convention over configuration principle. In this post, we'll explore the basics of Rails and how to get started with your first application.\n\nRails provides many built-in features that make web development faster and more enjoyable. From ActiveRecord for database interactions to ActionView for rendering templates, Rails has everything you need to build modern web applications.",
    user: admin_user,
    tenant: tenant1
  )
  blog1.tags << [ ruby_tag, rails_tag ]
  blog1.questions << [ question1 ]

  blog2 = Blog.create!(
    title: "Modern JavaScript Development",
    body: "JavaScript has evolved significantly over the years. With ES6+ features like async/await, destructuring, and modules, modern JavaScript development is more powerful than ever.\n\nIn this post, we'll explore some of the key features that every JavaScript developer should know and how to use them effectively in your projects.",
    user: viewer_user,
    tenant: tenant1
  )
  blog2.tags << [ javascript_tag ]
  blog2.questions << [ question3 ]

  puts "Created #{Blog.count} blogs for TechCorp"
end

# Create some data for StartupHub tenant
ApplicationRecord.with_tenant(tenant2) do
  startup_tag = Tag.create!(name: "startup", tenant: tenant2)
  business_tag = Tag.create!(name: "business", tenant: tenant2)

  startup_question = Question.create!(
    title: "How to validate a startup idea?",
    body: "I have a startup idea but I'm not sure if it's viable. What are the best ways to validate a startup idea before investing time and money?",
    user: startup_admin,
    tenant: tenant2
  )
  startup_question.tags << [ startup_tag, business_tag ]

  puts "Created data for StartupHub tenant"
end

puts "\nSeed data created successfully!"
puts "TechCorp tenant has #{tenant1.users.count} users, #{tenant1.questions.count} questions, #{tenant1.responses.count} responses"
puts "StartupHub tenant has #{tenant2.users.count} users, #{tenant2.questions.count} questions, #{tenant2.responses.count} responses"
puts "\nLogin credentials:"
puts "TechCorp Admin: alice@techcorp.com / password123"
puts "TechCorp Viewer: bob@techcorp.com / password123"
puts "TechCorp Readonly: charlie@techcorp.com / password123"
puts "StartupHub Admin: diana@startuphub.com / password123"
