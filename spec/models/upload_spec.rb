# frozen_string_literal: true

RSpec.describe Upload do
  it 'validates mandatory' do
    expect(subject).not_to be_valid # run validations
    expect(subject.errors[:user_id]).to include('is not a number')
    expect(subject.errors[:key]).to include('can\'t be blank')
    expect(subject.errors[:name]).to include('can\'t be empty')
    expect(subject.errors[:size]).to include('can\'t be empty') & exclude('is not a number')
  end

  it 'validates numericality' do
    subject.user_id = '-'
    subject.size = '!'
    subject.last_modified = 0.5
    expect(subject).not_to be_valid
    expect(subject.errors[:user_id]).to include('is not a number')
    expect(subject.errors[:size]).to include('is not a number')
    expect(subject.errors[:last_modified]).to include('must be an integer')
  end

  it 'validates presence' do
    subject.key = " \n"
    subject.name = ''
    expect(subject).not_to be_valid
    expect(subject.errors[:key]).to include('can\'t be blank')
    expect(subject.errors[:name]).to include('can\'t be empty')
  end

  it 'validates max-length' do
    subject.key = '-' * 60
    subject.name = '-' * 300
    subject.mime_type = '-' * 300
    expect(subject).not_to be_valid
    expect(subject.errors[:key]).to include('is too long (maximum is 50 characters)')
    expect(subject.errors[:name]).to include('is too long (maximum is 255 characters)')
    expect(subject.errors[:mime_type]).to include('is too long (maximum is 255 characters)')
  end

  it 'validates auto-fix path name' do
    expect(described_class.where(key: 'abc123').update_all(name: './xx')).to be_truthy
    expect(described_class.find_by(key: 'abc123')).to be_truthy & have_attributes(name: 'xx')
  end

  it 'validates key uniqueness' do
    subject.user_id = -1
    subject.key = 'abc123'
    subject.name = 'foo'
    subject.size = -1
    expect(subject).to be_valid
    expect { subject.save! }.to raise_error(ActiveRecord::RecordNotUnique, /duplicate key value violates unique/)
  end
end
