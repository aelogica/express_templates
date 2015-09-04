require 'test_helper'
require 'ostruct'
class CountrySelectTest < ActiveSupport::TestCase

  def assigns
    {person: ::Person.new}
  end

  def helpers
    mock_action_view do
      def people_path
        '/people'
      end
    end
  end


  test "country_select renders without an error" do
    assert arbre {
      express_form(:person) {
        country_select :country_code
      }
    }
  end

  test "can change label for country_select" do
    html = arbre {
      express_form(:person) {
        country_select :country_code, label: "Country"
      }
    }
    assert_match(/<label.*Country<\/label>/, html)
  end
end
