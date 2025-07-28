class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Tenant scoping for multi-tenancy
  def self.current_tenant
    Thread.current[:current_tenant]
  end

  def self.current_tenant=(tenant)
    Thread.current[:current_tenant] = tenant
  end

  def self.with_tenant(tenant)
    old_tenant = current_tenant
    self.current_tenant = tenant
    yield
  ensure
    self.current_tenant = old_tenant
  end
end
