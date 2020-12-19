# frozen_string_literal: true

RSpec.describe ActiveAdminSearch do
  subject { described_class.active_admin_search! }

  let(:method_options) { {} }

  it 'has a version number' do
    expect(ActiveAdminSearch::VERSION).not_to be nil
  end
end
