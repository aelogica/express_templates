module ExpressTemplates
  module Components
    module Forms
      class FileUpload < FormComponent

        contains -> {
          text :title
          text :description

          div(class: 'dropzone-previews')
          div(class: 'dz-preview dz-file-preview', id: 'preview-template'){
            div(class: 'dz-image'){
              img('data-dz-thumbnail' => true)
            }
            div(class: 'dz-details'){
              div(class: 'dz-filename'){
                span('data-dz-name' => true)
              }
              div(class: 'dz-size', 'data-dz-size' => true)
            }
          }
          include_dropzone
        }

        def include_dropzone
          script {
            %Q(
              $(document).ready(function() {
                var previewNode;
                Dropzone.autoDiscover = false;
                previewNode = $('#preview-template').get(0).outerHTML;
                $('#preview-template').remove();
                $('.dropzone').dropzone({
                  url: '/admin/sites/media_items',
                  paramName: 'media_item[file]',
                  autoProcessQueue: false,
                  uploadMultiple: false,
                  maxFiles: 1,
                  previewTemplate: previewNode,
                  previewsContainer: '.dropzone-previews',
                  success: function() {
                    console.log('successful upload');
                    return location.reload();
                  },
                  drop: function() {
                    $('.dz-message.dz-default').remove();
                    return $('.dropzone-previews').removeClass('hide');
                  },
                  maxfilesexceeded: function(file) {
                    this.removeAllFiles();
                    return this.addFile(file);
                  },
                  init: function() {
                    var myDropzone;
                    myDropzone = this;
                    return $('.submit-form').click(function(e) {
                      e.preventDefault();
                      e.stopPropagation();
                      return myDropzone.processQueue();
                    });
                  }
                });
                return $('.dz-message.dz-default').ready(function() {
                  var addedHtml;
                  $('.dz-message.dz-default').remove();
                  addedHtml = '<div class="dz-message dz-default"><span> Drop files here or click to upload. </span></div>';
                  $('.dropzone-previews').before(addedHtml);
                  return $('.dropzone-previews').addClass('hide');
                });
              });

              $(document).on('mouseover', '.dz-preview', function() {
                $('.dz-image').zIndex('-999');
                $('.dz-image > img').addClass('blur');
                return $('.dz-details').zIndex('999');
              }).on('mouseleave', '.dz-preview', function() {
                $('.dz-image').zIndex('999');
                $('.dz-details').zIndex('-999');
                return $('.dz-image > img').removeClass('blur');
              });
            ).html_safe
          }
        end
      end
    end
  end
end

