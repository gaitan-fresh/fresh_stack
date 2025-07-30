class AiSummarizer {
  constructor() {
    this.currentButton = null;
    this.originalButtonText = null;
    this.bindEvents();
  }

  bindEvents() {
    document.addEventListener('click', (e) => {
      if (e.target.matches('.ai-summarize-btn') || e.target.closest('.ai-summarize-btn')) {
        e.preventDefault();
        const button = e.target.matches('.ai-summarize-btn') ? e.target : e.target.closest('.ai-summarize-btn');
        this.handleSummarizeClick(button);
      }

      if (e.target.matches('.ai-summary-close') || e.target.matches('.ai-summary-modal')) {
        this.closeModal();
      }
    });

    // Close modal on Escape key
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        this.closeModal();
      }
    });
  }

  async handleSummarizeClick(button) {
    const url = button.dataset.url;
    const title = button.dataset.title;
    
    if (!url) {
      console.error('No URL provided for summarization');
      return;
    }

    // Prevent multiple clicks while processing
    if (button.disabled) {
      return;
    }

    // Store button reference and original text
    this.currentButton = button;
    this.originalButtonText = button.innerHTML;

    // Disable button and show loading state
    button.disabled = true;
    button.innerHTML = '<div class="ai-loading-spinner"></div> Generating...';

    try {
      this.showModal(title, this.getLoadingContent());
      
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken(),
          'Accept': 'application/json'
        }
      });

      const data = await response.json();

      if (data.success) {
        this.updateModalContent(data.summary);
      } else {
        this.showError(data.error || 'Failed to generate summary');
      }
    } catch (error) {
      console.error('Summarization error:', error);
      this.showError('Network error. Please check your connection and try again.');
    } finally {
      // Reset button state
      this.resetButtonState();
    }
  }

  showModal(title, content) {
    // Remove existing modal if any
    this.closeModal();

    const modal = document.createElement('div');
    modal.className = 'ai-summary-modal';
    modal.innerHTML = `
      <div class="ai-summary-content">
        <div class="ai-summary-header">
          <h3 class="ai-summary-title">
            <span class="magic-wand">🪄</span>
            AI Summary: ${this.escapeHtml(title)}
          </h3>
          <button class="ai-summary-close" title="Close summary">&times;</button>
        </div>
        <div class="ai-summary-body">
          ${content}
        </div>
      </div>
    `;

    document.body.appendChild(modal);
    document.body.style.overflow = 'hidden'; // Prevent background scrolling

    // Add click outside to close
    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        this.closeModal();
      }
    });
  }

  updateModalContent(summary) {
    const modalBody = document.querySelector('.ai-summary-body');
    if (modalBody) {
      modalBody.innerHTML = this.formatSummary(summary);
    }
  }

  closeModal() {
    const modal = document.querySelector('.ai-summary-modal');
    if (modal) {
      modal.remove();
      document.body.style.overflow = ''; // Restore scrolling
    }
    
    // Reset button state when modal is closed
    this.resetButtonState();
  }

  resetButtonState() {
    if (this.currentButton && this.originalButtonText) {
      this.currentButton.disabled = false;
      this.currentButton.innerHTML = this.originalButtonText;
      this.currentButton = null;
      this.originalButtonText = null;
    }
  }

  getLoadingContent() {
    return `
      <div class="ai-loading">
        <div class="ai-loading-spinner"></div>
        Generating AI summary... This may take a few seconds.
      </div>
    `;
  }

  showError(message) {
    const modalBody = document.querySelector('.ai-summary-body');
    if (modalBody) {
      modalBody.innerHTML = `
        <div class="ai-error">
          <strong>Error:</strong> ${this.escapeHtml(message)}
        </div>
      `;
    }
  }

  formatSummary(summary) {
    // Convert markdown-like formatting to HTML
    let formatted = this.escapeHtml(summary);
    
    // Convert **bold** to <strong>
    formatted = formatted.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
    
    // Convert numbered lists
    formatted = formatted.replace(/^\d+\.\s(.+)$/gm, '<li>$1</li>');
    formatted = formatted.replace(/(<li>.*<\/li>)/s, '<ol>$1</ol>');
    
    // Convert bullet points
    formatted = formatted.replace(/^[-*]\s(.+)$/gm, '<li>$1</li>');
    formatted = formatted.replace(/(<li>.*<\/li>)/s, '<ul>$1</ul>');
    
    // Convert line breaks to paragraphs
    formatted = formatted.split('\n\n').map(paragraph => {
      if (paragraph.trim() && !paragraph.includes('<li>') && !paragraph.includes('<ol>') && !paragraph.includes('<ul>')) {
        return `<p>${paragraph.trim()}</p>`;
      }
      return paragraph;
    }).join('');

    return formatted;
  }

  escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]');
    return token ? token.getAttribute('content') : '';
  }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  new AiSummarizer();
});

// Also initialize for Turbo navigation
document.addEventListener('turbo:load', () => {
  if (!window.aiSummarizer) {
    window.aiSummarizer = new AiSummarizer();
  }
});