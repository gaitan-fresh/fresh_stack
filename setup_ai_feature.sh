#!/bin/bash

echo "🚀 Setting up AI Summarization Feature for Fresh Stack"
echo "=================================================="

# Check if API key is provided
if [ -z "$1" ]; then
    echo "❌ Please provide your Google Gemini API key as an argument"
    echo "💡 Usage: ./setup_ai_feature.sh YOUR_API_KEY"
    echo "💡 Get your API key from: https://aistudio.google.com/app/apikey"
    exit 1
fi

API_KEY="$1"

# Validate API key format
if [[ ! $API_KEY =~ ^AIza.* ]]; then
    echo "⚠️  Warning: API key doesn't start with 'AIza'. Make sure it's correct."
fi

echo "✅ Setting up environment variable..."

# Add to current session
export GOOGLE_GEMINI_API_KEY="$API_KEY"

# Add to shell profile
SHELL_PROFILE=""
if [ -f ~/.zshrc ]; then
    SHELL_PROFILE=~/.zshrc
elif [ -f ~/.bashrc ]; then
    SHELL_PROFILE=~/.bashrc
elif [ -f ~/.bash_profile ]; then
    SHELL_PROFILE=~/.bash_profile
fi

if [ ! -z "$SHELL_PROFILE" ]; then
    # Check if already exists
    if grep -q "GOOGLE_GEMINI_API_KEY" "$SHELL_PROFILE"; then
        echo "📝 Updating existing API key in $SHELL_PROFILE"
        sed -i.bak "s/export GOOGLE_GEMINI_API_KEY=.*/export GOOGLE_GEMINI_API_KEY=\"$API_KEY\"/" "$SHELL_PROFILE"
    else
        echo "📝 Adding API key to $SHELL_PROFILE"
        echo "export GOOGLE_GEMINI_API_KEY=\"$API_KEY\"" >> "$SHELL_PROFILE"
    fi
    echo "✅ API key added to $SHELL_PROFILE"
else
    echo "⚠️  Could not find shell profile. You may need to set the environment variable manually."
fi

echo ""
echo "🧪 Testing API connection..."

# Test the API
ruby test_gemini_api.rb

echo ""
echo "🎉 Setup complete!"
echo "💡 To use in new terminal sessions, run: source $SHELL_PROFILE"
echo "💡 Or restart your terminal"
echo ""
echo "🚀 Start your Rails server: rails server"
echo "🔍 Look for the '🪄 Summarize with AI' buttons on questions and blogs!"