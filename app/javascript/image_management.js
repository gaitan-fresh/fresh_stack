class ImageManagement {
  constructor() {
    this.setupEventListeners();
  }
  
  setupEventListeners() {
    document.addEventListener('click', (e) => {
      if (e.target.classList.contains('delete-image-btn')) {
        e.preventDefault();
        this.deleteImage(e.target);
      }
    });
  }
  
  async deleteImage(button) {
    const imageId = button.dataset.imageId;
    const url = button.dataset.url;
    const imageItem = button.closest('.image-management-item');
    
    if (!confirm('Are you sure you want to delete this image?')) {
      return;
    }
    
    try {
      button.disabled = true;
      button.textContent = '...';
      
      const response = await fetch(url, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'application/json'
        }
      });
      
      if (response.ok) {
        // Animate removal
        imageItem.style.opacity = '0.5';
        imageItem.style.transform = 'scale(0.8)';
        
        setTimeout(() => {
          imageItem.remove();
          this.updateImageCount();
        }, 300);
        
        this.showSuccess('Image deleted successfully');
      } else {
        throw new Error('Failed to delete image');
      }
    } catch (error) {
      console.error('Error deleting image:', error);
      this.showError('Failed to delete image. Please try again.');
      
      // Reset button state
      button.disabled = false;
      button.textContent = '×';
    }
  }
  
  updateImageCount() {
    const existingImages = document.querySelector('.existing-images');
    const imageItems = existingImages?.querySelectorAll('.image-management-item');
    
    if (imageItems && imageItems.length === 0) {
      existingImages.style.display = 'none';
    }
  }
  
  showSuccess(message) {
    this.showMessage(message, 'success');
  }
  
  showError(message) {
    this.showMessage(message, 'error');
  }
  
  showMessage(message, type) {
    // Remove existing messages
    const existingMessage = document.querySelector('.image-management-message');
    if (existingMessage) {
      existingMessage.remove();
    }
    
    const messageDiv = document.createElement('div');
    messageDiv.className = `image-management-message alert alert-${type === 'success' ? 'success' : 'danger'}`;
    messageDiv.textContent = message;
    
    const container = document.querySelector('.existing-images') || document.querySelector('.form-container');
    if (container) {
      container.insertBefore(messageDiv, container.firstChild);
      
      // Auto-hide after 3 seconds
      setTimeout(() => {
        messageDiv.remove();
      }, 3000);
    }
  }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  new ImageManagement();
});

export default ImageManagement;