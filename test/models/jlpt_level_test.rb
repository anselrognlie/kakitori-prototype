# frozen_string_literal: true

require 'test_helper'

describe JlptLevel do
  let(:new_level) { JlptLevel.new(id: 1, label: '1') }

  it 'must have expected fields' do
    %i[id label].each do |field|
      expect(new_level).must_respond_to field
    end
  end

  it 'must be readonly' do
    rec = new_level
    expect do
      rec.save
    end.must_raise ActiveRecord::ReadOnlyRecord
  end

  it 'must be be able to seed' do
    JlptLevel.seed_db
    rec = JlptLevel.find_by_id(0)
    expect(rec).wont_be(:nil?)
    expect(rec.label).must_equal('invalid')
  end
end
