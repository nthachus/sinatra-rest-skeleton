# frozen_string_literal: true

RSpec.describe UserSession do
  it 'validates mandatory' do
    expect(subject).not_to be_valid # run validations
    expect(subject.errors[:user_id]).to include('is not a number')
    expect(subject.errors[:key]).to include('can\'t be blank')
  end

  it 'validates numericality' do
    subject.user_id = '-'
    expect(subject).not_to be_valid
    expect(subject.errors[:user_id]).to include('is not a number')
  end

  it 'validates only-integer' do
    subject.user_id = 0.5
    expect(subject).not_to be_valid
    expect(subject.errors[:user_id]).to include('must be an integer')
  end

  it 'validates presence' do
    subject.key = " \n"
    expect(subject).not_to be_valid
    expect(subject.errors[:key]).to include('can\'t be blank')
  end

  it 'validates max-length' do
    subject.key = '-' * 60
    expect(subject).not_to be_valid
    expect(subject.errors[:key]).to include('is too long (maximum is 50 characters)')
  end

  it 'validates JSON value field' do
    expect(described_class.find_by!(key: 'ssl-xx')).to have_attributes(value: be_kind_of(Hash))
  end

  it 'validates key uniqueness' do
    subject.user_id = -1
    subject.key = 'ssl-xx'
    expect(subject).to be_valid
    expect { subject.save }.to raise_error(ActiveRecord::RecordNotUnique, /duplicate key value violates unique/)
  end
end
