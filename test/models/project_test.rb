require 'test_helper'

describe Project do
  let(:project) { Project.new name: 'test project'}

  it 'must be valid' do
    value(project).must_be :valid?
  end
end
