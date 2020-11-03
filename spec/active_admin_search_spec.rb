# frozen_string_literal: true

RSpec.describe ActiveAdminSearch do
  let(:method_options) { {} }
  subject { described_class.active_admin_search! }
  it 'has a version number' do
    expect(ActiveAdminSearch::VERSION).not_to be nil
  end
end
