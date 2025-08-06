class ImageLightbox {
  constructor() {
    this.currentIndex = 0;
    this.images = [];
    this.modal = null;
    this.modalImg = null;
    this.prevBtn = null;
    this.nextBtn = null;
    
    this.createModal();
    this.setupEventListeners();
  }
  
  createModal() {
    this.modal = document.createElement('div');
    this.modal.className = 'lightbox-modal';
    this.modal.innerHTML = `
      <div class="lightbox-content">
        <button class="lightbox-close">&times;</button>
        <button class="lightbox-prev">&#8249;</button>
        <img class="lightbox-image" alt="Full size image">
        <button class="lightbox-next">&#8250;</button>
        <div class="lightbox-counter">
          <span class="current-image">1</span> / <span class="total-images">1</span>
        </div>
      </div>
    `;
    
    document.body.appendChild(this.modal);
    
    this.modalImg = this.modal.querySelector('.lightbox-image');
    this.prevBtn = this.modal.querySelector('.lightbox-prev');
    this.nextBtn = this.modal.querySelector('.lightbox-next');
    this.closeBtn = this.modal.querySelector('.lightbox-close');
    this.counter = this.modal.querySelector('.lightbox-counter');
    this.currentSpan = this.modal.querySelector('.current-image');
    this.totalSpan = this.modal.querySelector('.total-images');
  }
  
  setupEventListeners() {
    // Close modal
    this.closeBtn.addEventListener('click', () => this.close());
    this.modal.addEventListener('click', (e) => {
      if (e.target === this.modal) this.close();
    });
    
    // Navigation
    this.prevBtn.addEventListener('click', () => this.navigate(-1));
    this.nextBtn.addEventListener('click', () => this.navigate(1));
    
    // Keyboard navigation
    document.addEventListener('keydown', (e) => {
      if (!this.modal.classList.contains('active')) return;
      
      switch(e.key) {
        case 'Escape':
          this.close();
          break;
        case 'ArrowLeft':
          this.navigate(-1);
          break;
        case 'ArrowRight':
          this.navigate(1);
          break;
      }
    });
    
    // Touch/swipe support for mobile
    let startX = 0;
    let startY = 0;
    
    this.modalImg.addEventListener('touchstart', (e) => {
      startX = e.touches[0].clientX;
      startY = e.touches[0].clientY;
    });
    
    this.modalImg.addEventListener('touchend', (e) => {
      if (!startX || !startY) return;
      
      const endX = e.changedTouches[0].clientX;
      const endY = e.changedTouches[0].clientY;
      
      const diffX = startX - endX;
      const diffY = startY - endY;
      
      // Only handle horizontal swipes
      if (Math.abs(diffX) > Math.abs(diffY) && Math.abs(diffX) > 50) {
        if (diffX > 0) {
          this.navigate(1); // Swipe left - next image
        } else {
          this.navigate(-1); // Swipe right - previous image
        }
      }
      
      startX = 0;
      startY = 0;
    });
    
    // Initialize gallery click handlers
    this.initializeGalleries();
  }
  
  initializeGalleries() {
    document.querySelectorAll('.image-gallery').forEach(gallery => {
      const thumbnails = gallery.querySelectorAll('.gallery-thumbnail');
      
      thumbnails.forEach((thumbnail, index) => {
        thumbnail.addEventListener('click', (e) => {
          e.preventDefault();
          this.open(gallery, index);
        });
      });
    });
  }
  
  open(gallery, startIndex = 0) {
    this.images = Array.from(gallery.querySelectorAll('.gallery-thumbnail'));
    this.currentIndex = startIndex;
    
    this.updateImage();
    this.updateNavigation();
    this.updateCounter();
    
    this.modal.classList.add('active');
    document.body.style.overflow = 'hidden';
  }
  
  close() {
    this.modal.classList.remove('active');
    document.body.style.overflow = '';
  }
  
  navigate(direction) {
    this.currentIndex += direction;
    
    if (this.currentIndex < 0) {
      this.currentIndex = this.images.length - 1;
    } else if (this.currentIndex >= this.images.length) {
      this.currentIndex = 0;
    }
    
    this.updateImage();
    this.updateCounter();
  }
  
  updateImage() {
    const currentThumbnail = this.images[this.currentIndex];
    const fullSizeUrl = currentThumbnail.dataset.fullSize;
    
    this.modalImg.src = fullSizeUrl;
    this.modalImg.alt = currentThumbnail.alt;
  }
  
  updateNavigation() {
    this.prevBtn.style.display = this.images.length > 1 ? 'block' : 'none';
    this.nextBtn.style.display = this.images.length > 1 ? 'block' : 'none';
  }
  
  updateCounter() {
    this.currentSpan.textContent = this.currentIndex + 1;
    this.totalSpan.textContent = this.images.length;
    this.counter.style.display = this.images.length > 1 ? 'block' : 'none';
  }
}

// Initialize lightbox when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  new ImageLightbox();
});

export default ImageLightbox;