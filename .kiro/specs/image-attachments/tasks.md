# Image Attachments Feature - Implementation Plan

## Phase 1: Foundation Setup

- [x] 1. Setup Active Storage and basic configuration
  - Install and configure Active Storage for the Rails application
  - Set up local storage for development environment
  - Configure image processing with ImageMagick/libvips
  - _Requirements: 5.1, 5.2_

- [x] 2. Create database migrations for tenant isolation
  - Add tenant_id column to active_storage_blobs table
  - Create foreign key constraint to tenants table
  - Add database indexes for performance optimization
  - _Requirements: 7.1, 7.2_

- [x] 3. Implement tenant isolation service
  - Create TenantImageService class for blob tenant association
  - Implement tenant access verification methods
  - Add tenant-scoped queries for image retrieval
  - Write unit tests for tenant isolation logic
  - _Requirements: 7.1, 7.2, 7.3_

## Phase 2: Model Layer Implementation

- [x] 4. Add image attachments to Question model
  - Add has_many_attached :images to Question model
  - Implement image count validation (max 10 images)
  - Implement file size validation (max 5MB per image)
  - Implement content type validation for image formats
  - _Requirements: 1.2, 1.3, 6.1_

- [ ] 5. Add image attachments to Blog model
  - Add has_many_attached :images to Blog model
  - Implement image count validation (max 15 images)
  - Implement file size validation (max 5MB per image)
  - Implement content type validation for image formats
  - _Requirements: 2.2, 2.3, 6.1_

- [x] 6. Create image variant configurations
  - Define standard image variants (thumbnail, medium, large)
  - Implement variant generation service
  - Add image processing background jobs
  - Write tests for image variant generation
  - _Requirements: 5.2, 3.1_

## Phase 3: Controller Layer Implementation

- [x] 7. Create ImagesController for AJAX uploads
  - Implement create action for handling image uploads
  - Implement destroy action for individual image deletion
  - Implement show action for serving images with tenant verification
  - Add proper error handling and JSON responses
  - _Requirements: 1.4, 2.4, 4.3, 7.2_

- [x] 8. Update QuestionsController for image handling
  - Modify create action to handle image attachments
  - Modify update action to handle image additions/removals
  - Add image parameter handling in strong parameters
  - Implement image-tenant association in create/update flows
  - _Requirements: 1.5, 4.1, 4.4, 7.1_

- [x] 9. Update BlogsController for image handling
  - Modify create action to handle image attachments
  - Modify update action to handle image additions/removals
  - Add image parameter handling in strong parameters
  - Implement image-tenant association in create/update flows
  - _Requirements: 2.5, 4.1, 4.4, 7.1_

## Phase 4: Frontend Upload Interface

- [ ] 10. Create reusable image upload component
  - Build drag-and-drop upload interface
  - Implement file selection with multiple file support
  - Add client-side file validation (size, type, count)
  - Create preview thumbnail generation
  - _Requirements: 1.1, 1.4, 2.1, 2.4, 8.1_

- [ ] 11. Implement upload progress and error handling
  - Add upload progress indicators
  - Implement error message display for validation failures
  - Add retry functionality for failed uploads
  - Create loading states and user feedback
  - _Requirements: 6.3, 6.4, 3.4_

- [ ] 12. Add mobile-specific upload features
  - Implement camera capture integration
  - Add touch-friendly upload interface
  - Implement progressive loading for slow connections
  - Add mobile-optimized file selection
  - _Requirements: 8.1, 8.3, 8.5_

## Phase 5: Display and Gallery Implementation

- [ ] 13. Create image gallery component
  - Build responsive image grid layout
  - Implement thumbnail display with aspect ratio preservation
  - Add lazy loading for performance optimization
  - Create gallery component for questions and blogs
  - _Requirements: 1.6, 2.6, 3.1, 8.2_

- [ ] 14. Implement lightbox/modal functionality
  - Create modal component for full-size image viewing
  - Add navigation controls for browsing multiple images
  - Implement keyboard navigation support
  - Add swipe/touch navigation for mobile devices
  - _Requirements: 3.2, 3.3, 8.4_

- [ ] 15. Add image management in edit forms
  - Display existing images in edit forms
  - Add individual delete buttons for each image
  - Implement image reordering functionality
  - Show image upload interface alongside existing images
  - _Requirements: 4.1, 4.2, 4.5_

## Phase 6: Integration and Polish

- [ ] 16. Integrate upload components into question forms
  - Add image upload component to new question form
  - Add image upload component to edit question form
  - Implement form submission with image handling
  - Add validation error display in forms
  - _Requirements: 1.1, 1.4, 1.5_

- [ ] 17. Integrate upload components into blog forms
  - Add image upload component to new blog form
  - Add image upload component to edit blog form
  - Implement form submission with image handling
  - Add validation error display in forms
  - _Requirements: 2.1, 2.4, 2.5_

- [ ] 18. Integrate gallery components into content views
  - Add image gallery to question show pages
  - Add image gallery to blog show pages
  - Implement responsive gallery layout
  - Add fallback handling for missing images
  - _Requirements: 1.6, 2.6, 3.4, 3.5_

## Phase 7: Security and Performance

- [ ] 19. Implement security validations
  - Add content-type verification beyond file extension
  - Implement file signature checking
  - Add EXIF data stripping for privacy
  - Implement rate limiting for uploads
  - _Requirements: 6.1, 6.2, 6.5_

- [ ] 20. Add performance optimizations
  - Implement image caching headers
  - Add background job processing for large images
  - Implement CDN-ready URL generation
  - Add database query optimizations for image loading
  - _Requirements: 5.3, 5.2_

- [ ] 21. Implement cleanup and maintenance
  - Create background job for orphaned image cleanup
  - Add storage usage tracking per tenant
  - Implement automatic variant cleanup on image deletion
  - Add monitoring for storage capacity
  - _Requirements: 5.4, 5.5, 7.4_

## Phase 8: Testing and Quality Assurance

- [ ] 22. Write comprehensive unit tests
  - Test model validations for all image constraints
  - Test tenant isolation service functionality
  - Test image variant generation and processing
  - Test controller actions and error handling
  - _Requirements: All requirements coverage_

- [ ] 23. Write integration tests
  - Test complete upload workflow from form to storage
  - Test image display in content pages
  - Test edit/delete functionality
  - Test multi-tenant access control
  - _Requirements: All requirements coverage_

- [ ] 24. Write system tests for user workflows
  - Test end-to-end question creation with images
  - Test end-to-end blog creation with images
  - Test responsive gallery behavior across devices
  - Test mobile upload and viewing experience
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

## Phase 9: Documentation and Deployment

- [ ] 25. Create user documentation
  - Write user guide for image upload functionality
  - Create troubleshooting guide for common issues
  - Document mobile-specific features and limitations
  - Create admin guide for storage management
  - _Requirements: User experience optimization_

- [ ] 26. Prepare for production deployment
  - Configure production storage backend (AWS S3/similar)
  - Set up image processing infrastructure
  - Configure CDN for image serving
  - Set up monitoring and alerting for storage issues
  - _Requirements: 5.1, 5.3, 5.4_