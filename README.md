# Fresh Stack - StackOverflow Clone

A simplified StackOverflow clone built with Ruby on Rails featuring multi-tenant support, user authentication, questions & answers, voting, blogging, and tagging system.

## 🚀 Features

### Multi-Tenancy
- Each organization (tenant) has isolated data
- Users, questions, blogs, tags are scoped to tenants
- Complete data separation between tenants

### User Management & Authentication
- User registration and login
- Three user roles:
  - **Admin**: Can post questions, respond, vote, and manage content
  - **Viewer**: Can view, respond to questions, and vote
  - **Readonly**: Can only view content
- Secure password authentication with bcrypt

### Questions & Answers
- Admins can post questions
- Users can respond to questions and other responses (nested replies)
- Response acceptance system (question author can mark best answer)
- Voting system for questions and responses
- Tag-based categorization

### Blogging System
- Users can create blog posts
- Blog posts can be linked to related questions
- Tag-based organization
- Search functionality

### Voting & Engagement
- Upvote/downvote questions and responses
- Vote scores displayed prominently
- User-specific vote tracking (can't vote multiple times)

### Search & Discovery
- Search questions by title, body, tags, or author
- Filter by tags
- Related content suggestions

## 🛠️ Technology Stack

- **Backend**: Ruby on Rails 8.0.2
- **Database**: MySQL 8.0+
- **Authentication**: bcrypt (has_secure_password)
- **Frontend**: ERB templates with Turbo/Stimulus
- **Styling**: Custom CSS with responsive design

## 📋 Prerequisites

- Ruby 3.4.2+
- MySQL 8.0+
- Node.js (for asset pipeline)

## 🔧 Installation & Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd fresh_stack
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Database setup**
   ```bash
   # Create databases
   rails db:create
   
   # Run migrations
   rails db:migrate
   
   # Create test data (optional)
   ruby create_test_data.rb
   ```

4. **Start the server**
   ```bash
   rails server
   ```

5. **Access the application**
   - Open http://localhost:3000
   - Use test credentials if you ran the test data script

## 🗄️ Database Schema

### Core Tables
- `tenants` - Organization/tenant information
- `users` - User accounts with roles
- `questions` - Questions posted by users
- `responses` - Answers and comments (polymorphic)
- `votes` - Upvotes/downvotes for questions and responses
- `tags` - Categorization tags
- `blogs` - Blog posts
- `taggings` - Polymorphic join table for tags
- `blogs_questions` - Many-to-many relationship

### Key Relationships
- Users belong to tenants
- Questions have many responses (nested via polymorphic association)
- Questions and blogs can have multiple tags
- Blogs can be associated with multiple questions
- Votes can be for questions or responses

## 👥 User Roles & Permissions

| Action | Admin | Viewer | Readonly |
|--------|-------|--------|----------|
| View content | ✅ | ✅ | ✅ |
| Post questions | ✅ | ❌ | ❌ |
| Respond to questions | ✅ | ✅ | ❌ |
| Vote on content | ✅ | ✅ | ❌ |
| Create blog posts | ✅ | ✅ | ❌ |
| Accept answers | ✅ (own questions) | ✅ (own questions) | ❌ |

## 🔍 API Endpoints

### Authentication
- `GET /login` - Login form
- `POST /login` - Process login
- `DELETE /logout` - Logout
- `GET /signup` - Registration form
- `POST /users` - Create account

### Questions
- `GET /questions` - List questions
- `GET /questions/:id` - Show question with responses
- `GET /questions/new` - New question form (admin only)
- `POST /questions` - Create question (admin only)
- `POST /questions/:id/vote_up` - Upvote question
- `POST /questions/:id/vote_down` - Downvote question

### Responses
- `POST /questions/:id/responses` - Create response
- `POST /responses/:id/responses` - Create nested response
- `PATCH /responses/:id/accept` - Accept response
- `POST /responses/:id/vote_up` - Upvote response
- `POST /responses/:id/vote_down` - Downvote response

### Blogs
- `GET /blogs` - List blog posts
- `GET /blogs/:id` - Show blog post
- `GET /blogs/new` - New blog form
- `POST /blogs` - Create blog post

## 🎨 UI/UX Features

- **Responsive Design**: Works on desktop and mobile
- **Clean Interface**: Inspired by StackOverflow's design
- **Real-time Feedback**: Immediate vote updates
- **Search & Filtering**: Easy content discovery
- **Nested Comments**: Threaded discussions
- **Tag System**: Visual tag badges for categorization

## 🔒 Security Features

- Password hashing with bcrypt
- CSRF protection
- Role-based access control
- Tenant data isolation
- Input validation and sanitization

## 🧪 Testing

The application includes:
- Model validations
- Controller authorization
- Multi-tenant data isolation
- User role permissions

## 📝 Usage Examples

### Creating a Question (Admin)
1. Login as admin user
2. Click "Ask Question"
3. Fill in title, body, and select tags
4. Submit to post question

### Responding to Questions
1. Login as admin or viewer
2. Navigate to a question
3. Scroll to "Your Answer" section
4. Write response and submit

### Voting
1. Login as admin or viewer
2. Click ▲ or ▼ buttons next to questions/responses
3. Vote score updates immediately

### Creating Blog Posts
1. Login as any user
2. Navigate to Blogs section
3. Click "Write Post"
4. Fill in content and optionally link to questions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🆘 Support

For questions or issues:
1. Check the existing issues
2. Create a new issue with detailed description
3. Include steps to reproduce any bugs

---

**Fresh Stack** - Making knowledge sharing simple and organized! 🚀