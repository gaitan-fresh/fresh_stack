# Fresh-Stack - Product Design & Documentation

## 🏡 Overview

Fresh-Stack is a simplified StackOverflow clone built with **Ruby on Rails** that allows users to ask and answer questions (combined as responses), vote on them, and manage blog content. It includes user authentication, user roles, multi-tenant support, and tagging with search capabilities.

---

## 🔑 Key Features

### ✅ Tenancy Support

- Each record is scoped under a `Tenant`
- Users, questions, blogs, tags, etc. are tenant-isolated

### ✅ Users

- Sign up / Sign in (Authentication)
- Roles:
  - **Admin**: Can post questions, respond, and vote
  - **Viewer**: Can view and respond to questions
  - **Readonly**: Can only view questions
- Belongs to a tenant
- Create blog posts

### ✅ Questions

- Can be posted by admin users
- Can have multiple responses (answers/comments)
- Can have votes
- Can be associated with multiple tags
- Can be associated with multiple blogs
- Belongs to a tenant

### ✅ Responses (merged answers + comments)

- Belong to a user
- Belong to a question or another response (nested replies)
- Can be voted
- Optional `is_accepted` field for answers
- Belongs to a tenant

### ✅ Votes

- Upvote or downvote **questions and responses**
- Tied to users
- Belongs to a tenant

### ✅ Tags

- Attached to questions and blogs
- Many-to-many relationship (via `taggings` table with `taggable_type`)
- Belongs to a tenant

### ✅ Blogs

- Created by users
- Can be standalone
- Can be associated with one or more questions
- Can be associated with one or more tags
- Belongs to a tenant

### ✅ Search

- Search questions by title, body, tags, or author

---

## 🗄️ Database Schema

### `tenants`

| Column      | Type     | Constraints      |
| ----------- | -------- | ---------------- |
| id          | integer  | primary key      |
| name        | string   | not null, unique |
| created\_at | datetime |                  |
| updated\_at | datetime |                  |

### `users`

| Column           | Type     | Constraints                        |
| ---------------- | -------- | ---------------------------------- |
| id               | integer  | primary key                        |
| name             | string   | not null                           |
| email            | string   | not null, unique                   |
| password\_digest | string   | not null                           |
| role             | string   | not null, default: "viewer"        |
| tenant\_id       | integer  | foreign key → tenants.id, not null |
| created\_at      | datetime |                                    |
| updated\_at      | datetime |                                    |

### `questions`

| Column      | Type     | Constraints                        |
| ----------- | -------- | ---------------------------------- |
| id          | integer  | primary key                        |
| title       | string   | not null                           |
| body        | text     | not null                           |
| user\_id    | integer  | foreign key → users.id, not null   |
| tenant\_id  | integer  | foreign key → tenants.id, not null |
| created\_at | datetime |                                    |
| updated\_at | datetime |                                    |

### `responses`

| Column       | Type     | Constraints                                       |
| ------------ | -------- | ------------------------------------------------- |
| id           | integer  | primary key                                       |
| body         | text     | not null                                          |
| user\_id     | integer  | foreign key → users.id, not null                  |
| parent\_type | string   | polymorphic (Question or Response)                |
| parent\_id   | integer  | foreign key to Question or Response               |
| is\_accepted | boolean  | optional (true for accepted answer-like behavior) |
| tenant\_id   | integer  | foreign key → tenants.id, not null                |
| created\_at  | datetime |                                                   |
| updated\_at  | datetime |                                                   |

### `votes`

| Column       | Type     | Constraints                              |
| ------------ | -------- | ---------------------------------------- |
| id           | integer  | primary key                              |
| value        | integer  | not null (1 for upvote, -1 for downvote) |
| user\_id     | integer  | foreign key → users.id, not null         |
| question\_id | integer  | foreign key → questions.id, nullable     |
| response\_id | integer  | foreign key → responses.id, nullable     |
| tenant\_id   | integer  | foreign key → tenants.id, not null       |
| created\_at  | datetime |                                          |
| updated\_at  | datetime |                                          |

### `tags`

| Column      | Type     | Constraints                        |
| ----------- | -------- | ---------------------------------- |
| id          | integer  | primary key                        |
| name        | string   | not null, unique                   |
| tenant\_id  | integer  | foreign key → tenants.id, not null |
| created\_at | datetime |                                    |
| updated\_at | datetime |                                    |

### `blogs`

| Column      | Type     | Constraints                        |
| ----------- | -------- | ---------------------------------- |
| id          | integer  | primary key                        |
| title       | string   | not null                           |
| body        | text     | not null                           |
| user\_id    | integer  | foreign key → users.id, not null   |
| tenant\_id  | integer  | foreign key → tenants.id, not null |
| created\_at | datetime |                                    |
| updated\_at | datetime |                                    |

### `blogs_questions` (join table)

| Column       | Type    | Constraints                |
| ------------ | ------- | -------------------------- |
| blog\_id     | integer | foreign key → blogs.id     |
| question\_id | integer | foreign key → questions.id |

### `taggings` (unified join table for questions & blogs)

| Column         | Type    | Constraints                    |
| -------------- | ------- | ------------------------------ |
| tag\_id        | integer | foreign key → tags.id          |
| taggable\_id   | integer | polymorphic ID (question/blog) |
| taggable\_type | string  | "Question" or "Blog"           |

---

## 📁 Model Associations

### 👤 User

```ruby
has_secure_password
belongs_to :tenant
has_many :questions
has_many :responses
has_many :votes
has_many :blogs
```

### 🏢 Tenant

```ruby
has_many :users
has_many :questions
has_many :responses
has_many :votes
has_many :tags
has_many :blogs
```

### 🤔 Question

```ruby
belongs_to :user
belongs_to :tenant
has_many :responses, as: :parent
has_many :votes
has_many :taggings, as: :taggable
has_many :tags, through: :taggings
has_and_belongs_to_many :blogs
```

### 🗨️ Response

```ruby
belongs_to :user
belongs_to :tenant
belongs_to :parent, polymorphic: true
has_many :responses, as: :parent  # For nested replies
has_many :votes
```

### ⬆️ Vote

```ruby
belongs_to :user
belongs_to :tenant
belongs_to :question, optional: true
belongs_to :response, optional: true
```

### 🌿 Tag

```ruby
belongs_to :tenant
has_many :taggings
has_many :questions, through: :taggings, source: :taggable, source_type: "Question"
has_many :blogs, through: :taggings, source: :taggable, source_type: "Blog"
```

### 🏷️ Tagging

```ruby
belongs_to :tag
belongs_to :taggable, polymorphic: true
```

### 📄 Blog

```ruby
belongs_to :user
belongs_to :tenant
has_many :taggings, as: :taggable
has_many :tags, through: :taggings
has_and_belongs_to_many :questions
```

---

## 📄 Associations Explained

### belongs\_to

- Defines a one-to-one connection *from the child to the parent*
- Requires a foreign key (e.g., `tenant_id`, `user_id`)

### has\_many

- A one-to-many relationship from the parent to its children

### has\_and\_belongs\_to\_many (HABTM)

- Many-to-many relationship without an intermediate model
- Used for `questions_blogs`

### Polymorphic Associations

- **Responses** use polymorphic association to attach to either a `Question` or another `Response`
- **Taggings** allow tags to be reused across `Question` and `Blog`
- **Votes** are explicitly tied to `question` or `response`

---

## 🚀 Next Steps

1. Scaffold models for Tenant, User, Question, Blog, Response, Tag, Vote, and Tagging
2. Implement authentication and tenant-based access control
3. Add role-based permission checks
4. Setup routes and nested resources
5. Add voting, tagging, and search features
6. Build multi-tenant isolation into controllers and queries
7. Design UI for nested responses, tagging, and multi-tenant management

