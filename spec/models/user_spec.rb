# frozen_string_literal: true

RSpec.describe User do
  it 'validates mandatory' do
    expect(subject).not_to be_valid # run validations
    expect(subject.errors[:role]).to be_blank
    expect(subject.errors[:username]).to include('can\'t be blank')
    expect(subject.errors[:name]).to include('can\'t be blank')
  end

  it 'validates enumeration' do
    expect { subject.role = '!' }.to raise_error(/is not a valid role/)
  end

  it 'validates presence' do
    subject.username = " \n"
    subject.name = "\t \r"
    expect(subject).not_to be_valid
    expect(subject.errors[:username]).to include('can\'t be blank')
    expect(subject.errors[:name]).to include('can\'t be blank')
    expect(subject.errors[:email]).to be_blank
  end

  it 'validates max-length' do
    subject.username = '-' * 300
    subject.password = '-' * 100
    subject.name = '-' * 300
    subject.email = '-' * 300
    expect(subject).not_to be_valid
    expect(subject.errors[:username]).to include('is too long (maximum is 255 characters)')
    expect(subject.errors[:password]).to include('is too long (maximum is 72 characters)')
    expect(subject.errors[:name]).to include('is too long (maximum is 255 characters)')
    expect(subject.errors[:email]).to include('is too long (maximum is 255 characters)')
    expect(subject.errors[:password_confirmation]).to be_blank
  end

  it 'validates uniqueness' do
    subject.username = 'ssl'
    subject.email = 'SSL@Skeleton.xx'
    expect(subject).not_to be_valid
    expect(subject.errors[:username]).to include('has already been taken')
    expect(subject.errors[:email]).to include('has already been taken') & exclude('is invalid')
  end

  it 'validates password confirmation' do
    subject.password = '-'
    subject.password_confirmation = '!'
    expect(subject).not_to be_valid
    expect(subject.errors[:password_confirmation]).to include(/doesn't match password/i)
    expect(subject.errors[:created_by]).to be_blank
  end

  it 'validates numericality' do
    subject.created_by = '-'
    subject.updated_by = 0.5
    subject.deleted_by = '!'
    expect(subject).not_to be_valid
    expect(subject.errors[:created_by]).to include('is not a number')
    expect(subject.errors[:updated_by]).to include('must be an integer')
    expect(subject.errors[:deleted_by]).to include('is not a number')
  end

  it 'validates email format' do
    subject.email = '-'
    expect(subject).not_to be_valid
    expect(subject.errors[:email]).to include('is invalid')
  end

  it 'validates successfully' do
    subject.username = '-'
    subject.name = '!'
    expect(subject).to be_valid
  end
end
