# frozen_string_literal: true

require 'spec_helper'
describe 'concat_merge' do
  describe 'exception handling' do
    it {
      expect(subject).to run.with_params.and_raise_error(
        Puppet::ParseError, %r{wrong number of arguments}i
      )
    }

    it {
      expect(subject).to run.with_params({}).and_raise_error(
        Puppet::ParseError, %r{wrong number of arguments}i
      )
    }

    it {
      expect(subject).to run.with_params('2', 2).and_raise_error(
        Puppet::ParseError, %r{unexpected argument type}
      )
    }

    it {
      expect(subject).to run.with_params(2, '2').and_raise_error(
        Puppet::ParseError, %r{unexpected argument type}
      )
    }
  end

  describe 'collisions' do
    context 'single keys' do
      it {
        expect(subject).to run.with_params({
                                             'key1' => 'value1'
                                           }, {
                                             'key1' => 'value2'
                                           }).and_return({
                                                           'key1' => 'value2'
                                                         })
      }

      it {
        expect(subject).to run.with_params({
                                             'key1' => 'value1'
                                           }, {
                                             'key1' => 'value2'
                                           }, {
                                             'key1' => 'value3'
                                           }).and_return({
                                                           'key1' => 'value3'
                                                         })
      }
    end

    context 'multiple keys' do
      it {
        expect(subject).to run.with_params({
                                             'key1' => 'value1',
                                             'key2' => 'value2'
                                           }, {
                                             'key1' => 'value2'
                                           }).and_return({
                                                           'key1' => 'value2',
                                                           'key2' => 'value2'
                                                         })
      }

      it {
        expect(subject).to run.with_params({
                                             'key1' => 'value1',
                                             'key2' => 'value1'
                                           }, {
                                             'key1' => 'value2'
                                           }, {
                                             'key1' => 'value3',
                                             'key2' => 'value2'
                                           }).and_return({
                                                           'key1' => 'value3',
                                                           'key2' => 'value2'
                                                         })
      }
    end
  end

  describe 'concat merging' do
    context 'single keys' do
      it {
        expect(subject).to run.with_params({
                                             'key1' => ['value1']
                                           }, {
                                             'key1' => ['value2']
                                           }).and_return({
                                                           'key1' => %w[value1 value2]
                                                         })
      }

      it {
        expect(subject).to run.with_params({
                                             'key1' => ['value1']
                                           }, {
                                             'key1' => ['value2']
                                           }, {
                                             'key1' => ['value3']
                                           }).and_return({
                                                           'key1' => %w[value1 value2 value3]
                                                         })
      }

      it {
        expect(subject).to run.with_params({
                                             'key1' => ['value1']
                                           }, {
                                             'key1' => 'value2'
                                           }).and_return({
                                                           'key1' => 'value2'
                                                         })
      }

      it {
        expect(subject).to run.with_params({
                                             'key1' => 'value1'
                                           }, {
                                             'key1' => ['value2']
                                           }).and_return({
                                                           'key1' => ['value2']
                                                         })
      }
    end

    context 'multiple keys' do
      it {
        expect(subject).to run.with_params({
                                             'key1' => ['value1'],
                                             'key2' => ['value3']
                                           }, {
                                             'key1' => ['value2'],
                                             'key2' => ['value4']
                                           }).and_return({
                                                           'key1' => %w[value1 value2],
                                                           'key2' => %w[value3 value4]
                                                         })
      }

      it {
        expect(subject).to run.with_params({
                                             'key1' => ['value1'],
                                             'key2' => ['value1.1']
                                           }, {
                                             'key1' => ['value2'],
                                             'key2' => ['value2.1']
                                           }, {
                                             'key1' => ['value3'],
                                             'key2' => ['value3.1']
                                           }).and_return({
                                                           'key1' => %w[value1 value2 value3],
                                                           'key2' => ['value1.1', 'value2.1', 'value3.1']
                                                         })
      }

      it {
        expect(subject).to run.with_params({
                                             'key1' => ['value1'],
                                             'key2' => 'value1'
                                           }, {
                                             'key1' => 'value2',
                                             'key2' => ['value2']
                                           }).and_return({
                                                           'key1' => 'value2',
                                                           'key2' => ['value2']
                                                         })
      }

      it {
        expect(subject).to run.with_params({
                                             'key1' => 'value1',
                                             'key2' => ['value1']
                                           }, {
                                             'key1' => ['value2'],
                                             'key2' => 'value2'
                                           }).and_return(
                                             'key1' => ['value2'],
                                             'key2' => 'value2'
                                           )
      }
    end
  end

  it 'does not change the original hashes' do
    argument1 = { 'key1' => 'value1' }
    original1 = argument1.dup
    argument2 = { 'key2' => 'value2' }
    original2 = argument2.dup

    subject.execute(argument1, argument2)
    expect(argument1).to eq(original1)
    expect(argument2).to eq(original2)
  end
end
