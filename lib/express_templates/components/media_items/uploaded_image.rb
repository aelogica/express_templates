module ExpressTemplates
  module Components
    module MediaItems
      class UploadedImage < Configurable
        include ExpressTemplates::Components::Capabilities::Resourceful

        tag :div

        has_argument :id, 'The name of the slug that will be used to reference in the database',
                     as: :slug, type: [:symbol, :string]
        has_option :size, 'Choose from :icon, :thumb, :small, :medium, :large, or :full for full image', default: :thumb
        has_option :alt, 'Alternative text'

        before_build {
          add_class 'wip'
        }

        contains{
          image_tag(image_url, )
        }


        def image_url
          image = ExpressSite::MediaItem.find_by_slug(slug)
          image.decorate.size_url(size)
        end

        def size
          config[:size].to_s.titleize
        end

        def slug
          config[:slug]
        end

        def alt
          config[:alt] || 'image'
        end

      end
    end
  end
end
