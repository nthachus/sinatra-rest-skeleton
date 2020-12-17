# frozen_string_literal: true

RSpec.describe Upload do
  it 'validates mandatory' do
    expect(subject).not_to be_valid # run validations
    expect(subject.errors[:user_id]).to include('is not a number')
    expect(subject.errors[:key]).to include('can\'t be blank')
    expect(subject.errors[:filename]).to include('can\'t be empty')
    expect(subject.errors[:size]).to include('is not a number')
  end

  it 'validates numericality' do
    subject.user_id = '-'
    subject.size = 0.5
    subject.last_modified = '!'
    expect(subject).not_to be_valid
    expect(subject.errors[:user_id]).to include('is not a number')
    expect(subject.errors[:size]).to include('must be an integer')
    expect(subject.errors[:last_modified]).to include('is not a number')
  end

  it 'validates presence' do
    subject.key = " \n"
    subject.filename = ''
    expect(subject).not_to be_valid
    expect(subject.errors[:key]).to include('can\'t be blank')
    expect(subject.errors[:filename]).to include('can\'t be empty')
  end

  it 'validates max-length' do
    subject.key = '-' * 60
    subject.path = '-' * 300
    subject.filename = '-' * 300
    subject.mime_type = '-' * 300

    expect(subject).not_to be_valid
    expect(subject.errors[:key]).to include('is too long (maximum is 50 characters)')
    expect(subject.errors[:path]).to include('is too long (maximum is 255 characters)')
    expect(subject.errors[:filename]).to include('is too long (maximum is 255 characters)')
    expect(subject.errors[:mime_type]).to include('is too long (maximum is 255 characters)')
  end

  it 'validates uniqueness' do
    subject.user_id = 2
    subject.filename = 'xx'
    expect(subject).not_to be_valid
    expect(subject.errors[:filename]).to include('has already been taken')
  end

  it 'validates key uniqueness' do
    subject.user_id = -1
    subject.key = 'abc123'
    subject.filename = 'foo'
    subject.size = -1
    # expect(subject).to be_valid
    expect { subject.save! }.to raise_error(ActiveRecord::RecordNotUnique, /duplicate key value violates unique/)
  end
end
