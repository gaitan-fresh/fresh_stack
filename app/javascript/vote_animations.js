class VoteAnimations {
  constructor() {
    this.bindEvents();
  }

  bindEvents() {
    // Listen for unified vote button clicks
    document.addEventListener('click', (e) => {
      if (e.target.matches('.unified-vote-btn') || e.target.closest('.unified-vote-btn')) {
        const button = e.target.matches('.unified-vote-btn') ? e.target : e.target.closest('.unified-vote-btn');
        this.animateVoteButton(button);
      }
    });

    // Listen for successful vote updates
    document.addEventListener('vote:updated', (e) => {
      this.animateVoteDisplay(e.detail.voteDisplay);
    });
  }

  animateVoteButton(button) {
    // Add a pulse animation to the vote button
    button.style.transform = 'scale(0.95)';
    setTimeout(() => {
      button.style.transform = 'scale(1)';
    }, 150);
  }

  animateVoteDisplay(voteDisplay) {
    // Add update animation to vote display
    if (voteDisplay) {
      voteDisplay.classList.add('updated');
      setTimeout(() => {
        voteDisplay.classList.remove('updated');
      }, 300);
    }
  }

  // Method to update vote counts dynamically (for future AJAX updates)
  updateVoteCounts(element, upvotes, downvotes) {
    // Update unified vote buttons
    const upvoteBtn = element.querySelector('.unified-vote-btn.upvote .vote-count');
    const downvoteBtn = element.querySelector('.unified-vote-btn.downvote .vote-count');
    
    if (upvoteBtn) {
      upvoteBtn.textContent = upvotes;
      const upvoteButton = upvoteBtn.closest('.unified-vote-btn');
      upvoteButton.classList.add('updated');
      setTimeout(() => upvoteButton.classList.remove('updated'), 400);
    }

    if (downvoteBtn) {
      downvoteBtn.textContent = downvotes;
      const downvoteButton = downvoteBtn.closest('.unified-vote-btn');
      downvoteButton.classList.add('updated');
      setTimeout(() => downvoteButton.classList.remove('updated'), 400);
    }

    // Also update compact displays if present
    const voteDisplay = element.querySelector('.vote-display');
    if (voteDisplay) {
      const upvoteCount = voteDisplay.querySelector('.upvotes .vote-count');
      const downvoteCount = voteDisplay.querySelector('.downvotes .vote-count');
      const upvoteItem = voteDisplay.querySelector('.upvotes');
      const downvoteItem = voteDisplay.querySelector('.downvotes');

      if (upvoteCount) {
        upvoteCount.textContent = upvotes;
        upvoteItem.classList.toggle('zero', upvotes === 0);
      }

      if (downvoteCount) {
        downvoteCount.textContent = downvotes;
        downvoteItem.classList.toggle('zero', downvotes === 0);
      }

      this.animateVoteDisplay(voteDisplay);
    }
  }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  new VoteAnimations();
});

// Also initialize for Turbo navigation
document.addEventListener('turbo:load', () => {
  if (!window.voteAnimations) {
    window.voteAnimations = new VoteAnimations();
  }
});