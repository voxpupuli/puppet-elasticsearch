# frozen_string_literal: true

require 'spec_helper'

describe 'es_plugin_name' do
  describe 'exception handling' do
    it {
      expect(subject).to run.with_params.and_raise_error(
        Puppet::ParseError, %r{wrong number of arguments}i
      )
    }
  end

  describe 'single arguments' do
    it {
      expect(subject).to run.
        with_params('foo').
        and_return('foo')
    }

    it {
      expect(subject).to run.
        with_params('vendor/foo').
        and_return('foo')
    }

    it {
      expect(subject).to run.
        with_params('vendor/foo/1.0.0').
        and_return('foo')
    }

    it {
      expect(subject).to run.
        with_params('vendor/es-foo/1.0.0').
        and_return('foo')
    }

    it {
      expect(subject).to run.
        with_params('vendor/elasticsearch-foo/1.0.0').
        and_return('foo')
    }

    it {
      expect(subject).to run.
        with_params('com.foo:plugin_name:5.2.0').
        and_return('plugin_name')
    }

    it {
      expect(subject).to run.
        with_params('com:plugin_name:5.2.0-12').
        and_return('plugin_name')
    }

    it {
      expect(subject).to run.
        with_params('com.foo.bar:plugin_name:5').
        and_return('plugin_name')
    }
  end

  describe 'multiple arguments' do
    it {
      expect(subject).to run.
        with_params('foo', nil).
        and_return('foo')
    }

    it {
      expect(subject).to run.
        with_params(nil, 'foo').
        and_return('foo')
    }

    it {
      expect(subject).to run.
        with_params(nil, 0, 'foo', 'bar').
        and_return('foo')
    }
  end

  describe 'undef parameters' do
    it {
      expect(subject).to run.
        with_params('', 'foo').
        and_return('foo')
    }

    it {
      expect(subject).to run.
        with_params('').
        and_raise_error(Puppet::Error, %r{could not})
    }
  end

  it 'does not change the original values' do
    argument1 = 'foo'
    original1 = argument1.dup

    subject.execute(argument1)
    expect(argument1).to eq(original1)
  end
end
