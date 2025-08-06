class ImageUploader {
  constructor(container, options = {}) {
    this.container = container;
    this.maxFiles = parseInt(container.dataset.maxFiles) || 10;
    this.maxSize = parseInt(container.dataset.maxSize) || 5 * 1024 * 1024; // 5MB
    this.allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    this.files = [];
    
    this.dropzone = container.querySelector('.upload-dropzone');
    this.fileInput = container.querySelector('.file-input');
    this.previewsContainer = container.querySelector('.image-previews');
    this.progressContainer = container.querySelector('.upload-progress');
    this.progressBar = container.querySelector('.progress-fill');
    this.progressText = container.querySelector('.progress-text');
    
    // Debug logging
    console.log('ImageUploader initialized:', {
      container: this.container,
      dropzone: this.dropzone,
      fileInput: this.fileInput,
      maxFiles: this.maxFiles,
      maxSize: this.maxSize
    });
    
    if (!this.fileInput) {
      console.error('File input not found in container:', container);
      return;
    }
    
    this.setupEventListeners();
  }
  
  setupEventListeners() {
    if (!this.fileInput || !this.dropzone) {
      console.error('Required elements not found');
      return;
    }
    
    // File input change
    this.fileInput.addEventListener('change', (e) => {
      console.log('File input changed:', e.target.files);
      this.handleFiles(Array.from(e.target.files));
    });
    
    // Drag and drop
    this.dropzone.addEventListener('dragover', (e) => {
      e.preventDefault();
      this.dropzone.classList.add('drag-over');
    });
    
    this.dropzone.addEventListener('dragleave', (e) => {
      e.preventDefault();
      this.dropzone.classList.remove('drag-over');
    });
    
    this.dropzone.addEventListener('drop', (e) => {
      e.preventDefault();
      this.dropzone.classList.remove('drag-over');
      console.log('Files dropped:', e.dataTransfer.files);
      this.handleFiles(Array.from(e.dataTransfer.files));
    });
    
    // Click to browse - with better error handling
    this.dropzone.addEventListener('click', (e) => {
      e.preventDefault();
      console.log('Dropzone clicked, triggering file input');
      if (this.fileInput) {
        this.fileInput.click();
      } else {
        console.error('File input not available');
      }
    });
    
    // Prevent form submission on enter
    this.dropzone.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        this.fileInput.click();
      }
    });
  }
  
  handleFiles(newFiles) {
    const validFiles = newFiles.filter(file => this.validateFile(file));
    
    if (this.files.length + validFiles.length > this.maxFiles) {
      this.showError(`Cannot upload more than ${this.maxFiles} images`);
      return;
    }
    
    validFiles.forEach(file => {
      this.files.push(file);
      this.createPreview(file);
    });
    
    this.updateFileInput();
  }
  
  validateFile(file) {
    if (!this.allowedTypes.includes(file.type)) {
      this.showError(`${file.name} is not a valid image format`);
      return false;
    }
    
    if (file.size > this.maxSize) {
      this.showError(`${file.name} is too large (max ${this.maxSize / 1024 / 1024}MB)`);
      return false;
    }
    
    return true;
  }
  
  createPreview(file) {
    const previewItem = document.createElement('div');
    previewItem.className = 'preview-item';
    
    const img = document.createElement('img');
    img.className = 'preview-thumbnail';
    img.alt = file.name;
    
    const removeBtn = document.createElement('button');
    removeBtn.type = 'button';
    removeBtn.className = 'remove-preview-btn';
    removeBtn.innerHTML = '×';
    removeBtn.title = 'Remove image';
    
    removeBtn.addEventListener('click', () => {
      this.removeFile(file, previewItem);
    });
    
    previewItem.appendChild(img);
    previewItem.appendChild(removeBtn);
    this.previewsContainer.appendChild(previewItem);
    
    // Create preview using FileReader
    const reader = new FileReader();
    reader.onload = (e) => {
      img.src = e.target.result;
    };
    reader.readAsDataURL(file);
  }
  
  removeFile(file, previewElement) {
    const index = this.files.indexOf(file);
    if (index > -1) {
      this.files.splice(index, 1);
      previewElement.remove();
      this.updateFileInput();
    }
  }
  
  updateFileInput() {
    // Create a new DataTransfer object to update the file input
    const dt = new DataTransfer();
    this.files.forEach(file => dt.items.add(file));
    this.fileInput.files = dt.files;
  }
  
  showError(message) {
    // Create or update error message
    let errorDiv = this.container.querySelector('.upload-error');
    if (!errorDiv) {
      errorDiv = document.createElement('div');
      errorDiv.className = 'upload-error alert alert-danger';
      this.container.appendChild(errorDiv);
    }
    
    errorDiv.textContent = message;
    errorDiv.style.display = 'block';
    
    // Hide error after 5 seconds
    setTimeout(() => {
      errorDiv.style.display = 'none';
    }, 5000);
  }
  
  showProgress(show = true) {
    this.progressContainer.style.display = show ? 'block' : 'none';
  }
  
  updateProgress(percent, text = 'Uploading...') {
    this.progressBar.style.width = `${percent}%`;
    this.progressText.textContent = text;
  }
}

// Initialize uploaders when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  console.log('DOM loaded, initializing image uploaders');
  const containers = document.querySelectorAll('.image-upload-container');
  console.log('Found containers:', containers.length);
  
  containers.forEach((container, index) => {
    console.log(`Initializing uploader ${index + 1}`);
    try {
      new ImageUploader(container);
    } catch (error) {
      console.error('Error initializing uploader:', error);
    }
  });
});

// Also try to initialize on Turbo events for Rails
document.addEventListener('turbo:load', () => {
  console.log('Turbo loaded, initializing image uploaders');
  const containers = document.querySelectorAll('.image-upload-container');
  
  containers.forEach(container => {
    // Avoid double initialization
    if (!container.dataset.uploaderInitialized) {
      container.dataset.uploaderInitialized = 'true';
      try {
        new ImageUploader(container);
      } catch (error) {
        console.error('Error initializing uploader on turbo:load:', error);
      }
    }
  });
});

export default ImageUploader;