# Setting up Google Gemini AI Summarization

## Step 1: Get Google Gemini API Key
1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key" 
4. Select "Create API key in new project" or choose existing project
5. Copy the generated API key (starts with `AIza...`)

## Step 2: Install Required Gem
Run this command to install HTTParty for API requests:

```bash
bundle install
```

## Step 3: Add API Key (Choose One Method)

### Method A: Environment Variable (Easier for testing)
Set the environment variable in your terminal:

```bash
export GOOGLE_GEMINI_API_KEY="AIzaSyC-your_actual_api_key_here"
```

Or add it to your shell profile (`.bashrc`, `.zshrc`, etc.):
```bash
echo 'export GOOGLE_GEMINI_API_KEY="AIzaSyC-your_actual_api_key_here"' >> ~/.zshrc
source ~/.zshrc
```

### Method B: Rails Credentials (More secure for production)
Run this command in your terminal:

```bash
EDITOR="nano" rails credentials:edit
```

Add this line to your credentials file:
```yaml
google_gemini_api_key: AIzaSyC-your_actual_api_key_here
```

Save and close the file (Ctrl+X, then Y, then Enter in nano).

## Step 4: Verify Setup
Test in Rails console:

```ruby
rails console
Rails.application.credentials.google_gemini_api_key || ENV['GOOGLE_GEMINI_API_KEY']
# Should return your API key starting with "AIza"
```

Or test the environment variable directly:
```bash
echo $GOOGLE_GEMINI_API_KEY
```

## Step 5: Test the AI Service
Run the test script:

```bash
ruby test_ai_summarizer.rb
```

## Step 6: Start Your Server and Test
1. Start your Rails server: `rails server`
2. Navigate to a question or blog post
3. Click the "🪄 Summarize with AI" button
4. Wait for the AI-generated summary in the modal!

## API Endpoints Used
- **Questions**: `POST /questions/:id/summarize`
- **Blogs**: `POST /blogs/:id/summarize`

## Troubleshooting

### Common Issues:

1. **"API key not found in credentials"**
   - Make sure you saved the credentials file properly
   - Verify the key exists: `Rails.application.credentials.google_gemini_api_key`

2. **"API Error: 400"**
   - Check that your API key is valid
   - Make sure you enabled the Generative Language API in Google Cloud Console

3. **"Network error"**
   - Check your internet connection
   - Verify the API endpoint is accessible

4. **"Failed to generate summary"**
   - Check Rails logs: `tail -f log/development.log`
   - Look for detailed error messages

### Testing the API Directly:
```bash
curl -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [
      {
        "parts": [
          {
            "text": "Summarize this: Hello world"
          }
        ]
      }
    ]
  }'
```

### Enable API in Google Cloud Console:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Go to "APIs & Services" > "Library"
4. Search for "Generative Language API"
5. Click "Enable"

## Features:
- ✅ Summarizes questions with all answers
- ✅ Identifies accepted answers
- ✅ Includes vote scores and author information
- ✅ Summarizes blog posts with related questions
- ✅ Beautiful modal interface with loading states
- ✅ Error handling and fallbacks
- ✅ Mobile-responsive design