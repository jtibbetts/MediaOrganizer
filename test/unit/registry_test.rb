require '../test_helper'

class RegistryTest < ActiveSupport::TestCase
  test "Registry returns first value" do
    r = Registry.new
    assert_equal '/Users/johntibbetts/Music/MusicDirect', r['target_folder']
  end
end
