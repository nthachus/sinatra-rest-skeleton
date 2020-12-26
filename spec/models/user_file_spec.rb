# frozen_string_literal: true

RSpec.describe UserFile do
  it 'validates mandatory' do
    expect(subject).not_to be_valid # run validations
    expect(subject.errors[:user_id]).to include('is not a number')
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
    subject.name = ''
    expect(subject).not_to be_valid
    expect(subject.errors[:name]).to include('can\'t be empty')
  end

  it 'validates max-length' do
    subject.name = '-' * 300
    subject.media_type = '-' * 130
    subject.encoding = '-' * 60
    subject.checksum = 'a' * 110
    expect(subject).not_to be_valid
    expect(subject.errors[:name]).to include('is too long (maximum is 255 characters)') & exclude('has already been taken')
    expect(subject.errors[:media_type]).to include('is too long (maximum is 120 characters)')
    expect(subject.errors[:encoding]).to include('is too long (maximum is 50 characters)')
    expect(subject.errors[:checksum]).to include('is too long (maximum is 100 characters)') & exclude('is invalid')
  end

  it 'validates uniqueness' do
    subject.user_id = 2
    subject.name = 'abc.xx'
    subject.checksum = ''
    expect(subject).not_to be_valid
    expect(subject.errors[:name]).to include('has already been taken')

    expect(subject.errors.details_for?(:name, :taken)).to be_truthy
    expect(subject.errors[:checksum]).not_to include('is invalid')
  end

  it 'validates checksum format' do
    subject.checksum = '-'
    expect(subject).not_to be_valid
    expect(subject.errors[:checksum]).to include('is invalid')
  end

  it 'validates successfully' do
    subject.user_id = -1
    subject.name = '!'
    subject.size = -1
    expect(subject).to be_valid
    expect(subject.real_file_path).to be_truthy & satisfy { |f| !File.exist? f }
  end
end
