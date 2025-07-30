require "httparty"

class AiSummarizerService
  include HTTParty

  BASE_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"

  def initialize
    @api_key = Rails.application.credentials.google_gemini_api_key || ENV["GOOGLE_GEMINI_API_KEY"]
    raise "Google Gemini API key not found. Add to Rails credentials or set GOOGLE_GEMINI_API_KEY environment variable" if @api_key.blank?
  end

  def summarize_question(question)
    content = build_question_content(question)
    prompt = build_question_prompt(content)

    generate_summary(prompt)
  end

  def summarize_blog(blog)
    content = build_blog_content(blog)
    prompt = build_blog_prompt(content)

    generate_summary(prompt)
  end

  private

  def build_question_content(question)
    content = {
      title: question.title,
      body: question.body,
      author: question.user.name,
      tags: question.tags.pluck(:name),
      responses: []
    }

    # Add responses (answers)
    question.responses.includes(:user).each do |response|
      response_data = {
        body: response.body,
        author: response.user.name,
        is_accepted: response.is_accepted?,
        vote_score: response.vote_score,
        upvotes: response.upvotes_count,
        downvotes: response.downvotes_count
      }
      content[:responses] << response_data
    end

    content
  end

  def build_blog_content(blog)
    {
      title: blog.title,
      body: blog.body,
      author: blog.user.name,
      tags: blog.tags.pluck(:name),
      related_questions: blog.questions.pluck(:title)
    }
  end

  def build_question_prompt(content)
    prompt = <<~PROMPT
      Please provide a concise summary of this Stack Overflow-style question and its answers.

      **Question:**
      Title: #{content[:title]}
      Author: #{content[:author]}
      Tags: #{content[:tags].join(', ')}

      Body: #{content[:body]}

      **Answers (#{content[:responses].count}):**
    PROMPT

    content[:responses].each_with_index do |response, index|
      status = response[:is_accepted] ? " ✅ ACCEPTED" : ""
      prompt += <<~RESPONSE

        Answer #{index + 1}#{status} (👍 #{response[:upvotes]} | 👎 #{response[:downvotes]}):
        By: #{response[:author]}
        #{response[:body]}
      RESPONSE
    end

    prompt += <<~SUMMARY_REQUEST

      **Please provide:**
      1. A brief summary of the question (2-3 sentences)
      2. Key points from the answers
      3. The accepted solution (if any)
      4. Overall conclusion/recommendation

      Keep the summary concise but informative, suitable for quick understanding.
    SUMMARY_REQUEST

    prompt
  end

  def build_blog_prompt(content)
    prompt = <<~PROMPT
      Please provide a concise summary of this blog post.

      **Blog Post:**
      Title: #{content[:title]}
      Author: #{content[:author]}
      Tags: #{content[:tags].join(', ')}

      Content: #{content[:body]}
    PROMPT

    if content[:related_questions].any?
      prompt += <<~RELATED

        **Related Questions:**
        #{content[:related_questions].join(', ')}
      RELATED
    end

    prompt += <<~SUMMARY_REQUEST

      **Please provide:**
      1. A brief summary of the main topic (2-3 sentences)
      2. Key points or takeaways
      3. Target audience or use cases
      4. Overall conclusion

      Keep the summary concise but informative, suitable for quick understanding.
    SUMMARY_REQUEST

    prompt
  end

  def generate_summary(prompt)
    begin
      response = HTTParty.post(
        "#{BASE_URL}?key=#{@api_key}",
        headers: {
          "Content-Type" => "application/json"
        },
        body: {
          contents: [
            {
              parts: [
                {
                  text: prompt
                }
              ]
            }
          ],
          generationConfig: {
            temperature: 0.3,
            maxOutputTokens: 500,
            topP: 0.8,
            topK: 40
          }
        }.to_json
      )

      if response.success?
        # Extract the generated text from Gemini API response
        candidates = response.parsed_response.dig("candidates")
        if candidates && candidates.any?
          text = candidates.first.dig("content", "parts", 0, "text")
          return text if text.present?
        end

        "Unable to generate summary from the response."
      else
        Rails.logger.error "Gemini API Error: #{response.code} - #{response.body}"
        "Sorry, I couldn't generate a summary at this time. API Error: #{response.code}"
      end
    rescue => e
      Rails.logger.error "AI Summarization failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      "Sorry, I couldn't generate a summary at this time. Please try again later."
    end
  end
end
