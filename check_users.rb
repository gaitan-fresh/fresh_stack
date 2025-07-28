#!/usr/bin/env ruby
require_relative 'config/environment'

puts "Checking existing data..."
puts "Tenants: #{Tenant.count}"
puts "Users: #{User.count}"

if User.count == 0
  puts "\nNo users found. Creating test user..."

  # Create tenant if it doesn't exist
  tenant = Tenant.find_or_create_by(name: "TechCorp")

  # Create admin user
  admin = User.create!(
    name: "Admin User",
    email: "admin@techcorp.com",
    password: "password123",
    password_confirmation: "password123",
    role: "admin",
    tenant: tenant
  )

  puts "Created admin user: #{admin.email}"
  puts "Password: password123"
else
  puts "\nExisting users:"
  User.all.each do |user|
    puts "- #{user.email} (#{user.role}) - Tenant: #{user.tenant.name}"
  end
end

puts "\nYou can now login with any of the above credentials using password: password123"
