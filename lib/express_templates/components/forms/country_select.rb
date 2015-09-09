require 'countries'
require_relative 'select'

module ExpressTemplates
  module Components
    module Forms
      class CountrySelect < Select

        def select_options
          country_options = ISO3166::Country.all.map {|country| [country.name.titleize, country.alpha2]}
          us = country_options.delete(['United States', 'US'])
          country_options.unshift us
          helpers.options_for_select(country_options, selected_value)
        end

        def select_helper_options
          add_select2_class( input_attributes.merge(include_blank: false, prompt: "-- Please Select --" ) )
        end

      end
    end
  end
end
