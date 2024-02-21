# frozen_string_literal: true

require 'spec_helper'
describe 'es_hash2properties' do
  describe 'exception handling' do
    it {
      expect(subject).to run.with_params.and_raise_error(
        Puppet::ParseError, %r{wrong number of arguments}i
      )
    }

    it {
      expect(subject).to run.with_params('1').and_raise_error(
        Puppet::ParseError, %r{expected first argument}
      )
    }

    it {
      expect(subject).to run.with_params({ 'a' => 1 }, '2').and_raise_error(
        Puppet::ParseError, %r{expected second argument}
      )
    }
  end

  describe 'conversion' do
    context 'simple keys' do
      it {
        expect(subject).to run.with_params({
                                             'key1' => 'value1',
                                             'key2' => 0,
                                             'key3' => true,
                                           }).and_return(['# THIS FILE IS MANAGED BY PUPPET', 'key1 = value1', 'key2 = 0', 'key3 = true', ''].join("\n"))
      }
    end

    context 'keys and subkeys' do
      it {
        expect(subject).to run.with_params({
                                             'key1' => { 'subkey1' => 'value1', 'subkey2' => 0, },
                                             'key2' => true,
                                           }).and_return(['# THIS FILE IS MANAGED BY PUPPET', 'key1.subkey1 = value1', 'key1.subkey2 = 0', 'key2 = true', ''].join("\n"))
      }
    end

    context 'options header' do
      it {
        expect(subject).to run.with_params({
                                             'key1' => 'value1',
                                             'key2' => 0,
                                             'key3' => true,
                                           },
                                           {
                                             'header' => '# CUSTOM HEADER',
                                           }).and_return(['# CUSTOM HEADER', 'key1 = value1', 'key2 = 0', 'key3 = true', ''].join("\n"))
      }
    end
  end

  it 'does not change the original hashes' do
    argument1 = { 'key1' => 'value1' }
    original1 = argument1.dup

    subject.execute(argument1)
    expect(argument1).to eq(original1)
  end
end
