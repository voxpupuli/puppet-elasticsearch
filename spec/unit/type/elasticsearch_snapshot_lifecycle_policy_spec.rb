require_relative '../../helpers/unit/type/elasticsearch_rest_shared_examples'

describe Puppet::Type.type(:elasticsearch_snapshot_lifecycle_policy) do
  let(:resource_name) { 'test_policy' }

  let(:default_params) do
    {
      :repository => 'my_repository'
    }
  end

  describe 'attribute validation for elasticsearch_snapshot_lifecycle_policy' do
    [
      :name,
      :host,
      :port,
      :protocol,
      :validate_tls,
      :ca_file,
      :ca_path,
      :timeout,
      :username,
      :password,
      :type
    ].each do |param|
      it "should have a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    [
      :ensure,
      :schedule_time,
      :repository,
      :snapshot_name,
      :config_include_global_state,
      :config_ignore_unavailable,
      :config_partial,
      :config_indices,
      :retention_expire_after,
      :retention_min_count,
      :retention_max_count
    ].each do |prop|
      it "should have a #{prop} property" do
        expect(described_class.attrtype(prop)).to eq(:property)
      end
    end

    describe 'namevar validation' do
      it 'should have :name as its namevar' do
        expect(described_class.key_attributes).to eq([:name])
      end
    end

    describe 'ensure' do
      it 'should support present as a value for ensure' do
        expect do
          described_class.new(
            default_params.merge(
              :name => resource_name,
              :ensure => :present
            )
          )
        end.to_not raise_error
      end

      it 'should support absent as a value for ensure' do
        expect do
          described_class.new(
            default_params.merge(
              :name => resource_name,
              :ensure => :absent
            )
          )
        end.to_not raise_error
      end

      it 'should not support other values' do
        expect do
          described_class.new(
            default_params.merge(
              :name => resource_name,
              :ensure => :foo
            )
          )
        end.to raise_error(Puppet::Error, /Invalid value/)
      end
    end

    describe 'schedule_time' do
      it 'should be required' do
        expect do
          described_class.new(
            :name => resource_name
          )
        end.to raise_error(Puppet::Error, /Schedule_time is required./)
      end
    end

    describe 'repository' do
      it 'should be required' do
        expect do
          described_class.new(
            :name => resource_name
          )
        end.to raise_error(Puppet::Error, /Repository is required./)
      end
    end

    describe 'config_include_global_state' do
      [-1, 0, {}, [], 'foo'].each do |value|
        it "should reject invalid config_include_global_state value #{value}" do
          expect do
            described_class.new(
              default_params.merge(
                :name                        => resource_name,
                :config_include_global_state => value
              )
            )
          end.to raise_error(Puppet::Error, /invalid value/i)
        end
      end

      [true, false, 'true', 'false', 'yes', 'no'].each do |value|
        it "should accept config_include_global_state value #{value}" do
          expect do
            described_class.new(
              default_params.merge(
                :name                        => resource_name,
                :config_include_global_state => value
              )
            )
          end.not_to raise_error
        end
      end
    end

    describe 'config_ignore_unavailable' do
      [-1, 0, {}, [], 'foo'].each do |value|
        it "should reject invalid config_ignore_unavailable value #{value}" do
          expect do
            described_class.new(
              default_params.merge(
                :name                      => resource_name,
                :config_ignore_unavailable => value
              )
            )
          end.to raise_error(Puppet::Error, /invalid value/i)
        end
      end

      [true, false, 'true', 'false', 'yes', 'no'].each do |value|
        it "should accept config_ignore_unavailable value #{value}" do
          expect do
            described_class.new(
              default_params.merge(
                :name                      => resource_name,
                :config_ignore_unavailable => value
              )
            )
          end.not_to raise_error
        end
      end
    end

    describe 'config_partial' do
      [-1, 0, {}, [], 'foo'].each do |value|
        it "should reject invalid config_partial value #{value}" do
          expect do
            described_class.new(
              default_params.merge(
                :name           => resource_name,
                :config_partial => value
              )
            )
          end.to raise_error(Puppet::Error, /invalid value/i)
        end
      end

      [true, false, 'true', 'false', 'yes', 'no'].each do |value|
        it "should accept config_partial value #{value}" do
          expect do
            described_class.new(
              default_params.merge(
                :name           => resource_name,
                :config_partial => value
              )
            )
          end.not_to raise_error
        end
      end
    end

    describe 'retention_min_count' do
      [-1, 0, 70_000, 'foo'].each do |value|
        it "should reject invalid retention_min_count value #{value}" do
          expect do
            described_class.new(
              default_params.merge(
                :name                => resource_name,
                :retention_min_count => value
              )
            )
          end.to raise_error(Puppet::Error, /invalid retention_min_count/i)
        end
      end
    end

    describe 'retention_max_count' do
      [-1, 0, 70_000, 'foo'].each do |value|
        it "should reject invalid retention_max_count value #{value}" do
          expect do
            described_class.new(
              default_params.merge(
                :name                => resource_name,
                :retention_max_count => value
              )
            )
          end.to raise_error(Puppet::Error, /invalid retention_max_count/i)
        end
      end
    end

    describe 'host' do
      it 'should accept IP addresses' do
        expect do
          described_class.new(
            default_params.merge(
              :name => resource_name,
              :host => '127.0.0.1'
            )
          )
        end.not_to raise_error
      end
    end

    describe 'port' do
      [-1, 0, 70_000, 'foo'].each do |value|
        it "should reject invalid port value #{value}" do
          expect do
            described_class.new(
              default_params.merge(
                :name => resource_name,
                :port => value
              )
            )
          end.to raise_error(Puppet::Error, /invalid port/i)
        end
      end
    end

    describe 'validate_tls' do
      [-1, 0, {}, [], 'foo'].each do |value|
        it "should reject invalid ssl_verify value #{value}" do
          expect do
            described_class.new(
              default_params.merge(
                :name => resource_name,
                :validate_tls => value
              )
            )
          end.to raise_error(Puppet::Error, /invalid value/i)
        end
      end

      [true, false, 'true', 'false', 'yes', 'no'].each do |value|
        it "should accept validate_tls value #{value}" do
          expect do
            described_class.new(
              default_params.merge(
                :name => resource_name,
                :validate_tls => value
              )
            )
          end.not_to raise_error
        end
      end
    end

    describe 'timeout' do
      it 'should reject string values' do
        expect do
          described_class.new(
            default_params.merge(
              :name => resource_name,
              :timeout => 'foo'
            )
          )
        end.to raise_error(Puppet::Error, /must be a/)
      end

      it 'should reject negative integers' do
        expect do
          described_class.new(
            default_params.merge(
              :name => resource_name,
              :timeout => -10
            )
          )
        end.to raise_error(Puppet::Error, /must be a/)
      end

      it 'should accept integers' do
        expect do
          described_class.new(
            default_params.merge(
              :name => resource_name,
              :timeout => 10
            )
          )
        end.to_not raise_error
      end

      it 'should accept quoted integers' do
        expect do
          described_class.new(
            default_params.merge(
              :name => resource_name,
              :timeout => '10'
            )
          )
        end.to_not raise_error
      end
    end
  end # of describing when validing values include_examples 'REST API types', 'snapshot_repository'
end # of describe Puppet::Type
