# Image Attachments Feature - Design Document

## Overview

The image attachments feature will leverage Rails Active Storage to provide a robust, scalable solution for handling image uploads in the Fresh Stack application. The design follows Rails conventions while ensuring multi-tenant isolation, security, and optimal performance.

## Architecture

### High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Rails App     │    │   Storage       │
│                 │    │                 │    │                 │
│ • Upload UI     │◄──►│ • Controllers   │◄──►│ • Active Storage│
│ • Image Gallery │    │ • Models        │    │ • Local/Cloud   │
│ • Lightbox      │    │ • Validations   │    │ • Variants      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Component Interaction Flow

1. **Upload Flow**: User selects images → Frontend validates → Controller processes → Active Storage saves → Database records associations
2. **Display Flow**: User views content → Controller fetches with images → Views render gallery → Frontend handles interactions
3. **Management Flow**: User edits content → Shows existing images → Allows add/remove → Updates associations

## Components and Interfaces

### 1. Database Schema

#### Active Storage Tables (Built-in)
```sql
-- active_storage_blobs: Stores file metadata
-- active_storage_attachments: Polymorphic join table
-- active_storage_variant_records: Stores processed variants
```

#### Custom Extensions
```sql
-- Add tenant_id to active_storage_blobs for multi-tenant isolation
ALTER TABLE active_storage_blobs ADD COLUMN tenant_id INT;
ALTER TABLE active_storage_blobs ADD FOREIGN KEY (tenant_id) REFERENCES tenants(id);
```

### 2. Model Layer

#### Question Model Extensions
```ruby
class Question < ApplicationRecord
  # Existing associations...
  has_many_attached :images
  
  # Validations
  validate :images_count_limit
  validate :images_size_limit
  validate :images_content_type
  
  private
  
  def images_count_limit
    errors.add(:images, 'cannot exceed 10 images') if images.count > 10
  end
end
```

#### Blog Model Extensions
```ruby
class Blog < ApplicationRecord
  # Existing associations...
  has_many_attached :images
  
  # Validations (similar to Question but with 15 image limit)
end
```

#### Tenant Isolation Service
```ruby
class TenantImageService
  def self.attach_to_tenant(blob, tenant)
    blob.update!(tenant_id: tenant.id)
  end
  
  def self.tenant_accessible?(blob, tenant)
    blob.tenant_id == tenant.id
  end
end
```

### 3. Controller Layer

#### Images Controller (New)
```ruby
class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_imageable
  
  def create
    # Handle AJAX image uploads
    # Return JSON with image data for preview
  end
  
  def destroy
    # Handle individual image deletion
    # Verify ownership and tenant access
  end
  
  def show
    # Serve images with tenant verification
    # Handle different variants (thumbnail, medium, large)
  end
end
```

#### Questions/Blogs Controller Updates
```ruby
# Add image handling to existing create/update actions
def create
  @question = current_tenant.questions.build(question_params)
  @question.user = current_user
  
  if @question.save
    attach_images if params[:images].present?
    # Process tags...
    redirect_to @question
  else
    render :new
  end
end

private

def attach_images
  params[:images].each do |image|
    blob = @question.images.attach(image)
    TenantImageService.attach_to_tenant(blob.blob, current_tenant)
  end
end
```

### 4. View Layer

#### Upload Interface Component
```erb
<!-- Reusable partial: _image_upload.html.erb -->
<div class="image-upload-container">
  <div class="upload-dropzone" data-max-files="<%= max_files %>">
    <input type="file" multiple accept="image/*" class="file-input">
    <div class="upload-prompt">
      <i class="upload-icon">📷</i>
      <p>Drag & drop images here or click to browse</p>
      <small>Max <%= max_files %> images, 5MB each</small>
    </div>
  </div>
  
  <div class="image-previews">
    <!-- Dynamic preview thumbnails -->
  </div>
</div>
```

#### Image Gallery Component
```erb
<!-- Reusable partial: _image_gallery.html.erb -->
<div class="image-gallery" data-lightbox="content-gallery">
  <% images.each_with_index do |image, index| %>
    <div class="gallery-item">
      <%= image_tag image.variant(resize_to_limit: [300, 200]), 
                    class: "gallery-thumbnail",
                    data: { 
                      lightbox_index: index,
                      full_size: url_for(image.variant(resize_to_limit: [1200, 800]))
                    } %>
    </div>
  <% end %>
</div>
```

### 5. Frontend JavaScript

#### Upload Handler
```javascript
class ImageUploader {
  constructor(container, options = {}) {
    this.container = container;
    this.maxFiles = options.maxFiles || 10;
    this.maxSize = options.maxSize || 5 * 1024 * 1024; // 5MB
    this.setupEventListeners();
  }
  
  setupEventListeners() {
    // Drag & drop handling
    // File selection handling
    // Preview generation
    // Progress tracking
  }
  
  validateFile(file) {
    // Size validation
    // Type validation
    // Count validation
  }
  
  uploadFile(file) {
    // AJAX upload with progress
    // Error handling
    // Success callback
  }
}
```

#### Lightbox Component
```javascript
class ImageLightbox {
  constructor(gallery) {
    this.gallery = gallery;
    this.currentIndex = 0;
    this.images = gallery.querySelectorAll('.gallery-thumbnail');
    this.setupModal();
  }
  
  open(index) {
    // Show modal
    // Load image
    // Setup navigation
  }
  
  navigate(direction) {
    // Previous/next image
    // Keyboard support
    // Touch/swipe support
  }
}
```

## Data Models

### Image Attachment Flow

```
Question/Blog ──has_many_attached──► Images (Active Storage)
     │                                      │
     │                                      ▼
     └──belongs_to──► Tenant ◄──tenant_id── Blob
```

### Image Variants Strategy

```ruby
# Predefined variants for consistent sizing
VARIANTS = {
  thumbnail: { resize_to_limit: [150, 150] },
  medium: { resize_to_limit: [600, 400] },
  large: { resize_to_limit: [1200, 800] }
}
```

### Storage Structure

```
storage/
├── tenant_1/
│   ├── questions/
│   │   └── question_123/
│   │       ├── original_image.jpg
│   │       ├── thumbnail_image.jpg
│   │       └── medium_image.jpg
│   └── blogs/
│       └── blog_456/
│           └── images...
└── tenant_2/
    └── ...
```

## Error Handling

### Validation Errors
- File size exceeded
- Invalid file type
- Too many files
- Upload failed

### Runtime Errors
- Storage unavailable
- Image processing failed
- Tenant access denied
- Network timeout

### Error Response Format
```json
{
  "success": false,
  "errors": [
    {
      "field": "images",
      "message": "File size cannot exceed 5MB",
      "code": "FILE_TOO_LARGE"
    }
  ]
}
```

## Testing Strategy

### Unit Tests
- Model validations (file size, count, type)
- Tenant isolation service
- Image variant generation
- Upload processing logic

### Integration Tests
- Complete upload flow
- Image display in content
- Edit/delete functionality
- Multi-tenant access control

### System Tests
- End-to-end upload workflow
- Responsive gallery behavior
- Lightbox functionality
- Mobile upload experience

### Performance Tests
- Large file upload handling
- Multiple concurrent uploads
- Image serving performance
- Storage cleanup efficiency

## Security Considerations

### File Validation
- Content-type verification
- File signature checking
- Malware scanning integration
- EXIF data stripping

### Access Control
- Tenant-based isolation
- User ownership verification
- Secure URL generation
- Rate limiting on uploads

### Storage Security
- Encrypted storage at rest
- Secure file serving
- Temporary URL generation
- Access logging

## Performance Optimizations

### Image Processing
- Background job processing for variants
- Lazy loading of images
- Progressive image enhancement
- CDN integration ready

### Caching Strategy
- Browser caching headers
- Variant caching
- Gallery pagination
- Thumbnail preloading

### Database Optimization
- Eager loading of attachments
- Efficient queries for image metadata
- Index optimization for tenant filtering
- Cleanup of orphaned records

## Mobile and Responsive Design

### Upload Interface
- Touch-friendly drag zones
- Camera integration
- Progress indicators
- Offline upload queuing

### Gallery Display
- Responsive grid layout
- Touch/swipe navigation
- Lazy loading
- Bandwidth-aware loading

### Performance on Mobile
- Optimized image sizes
- Progressive loading
- Reduced data usage options
- Offline viewing capability