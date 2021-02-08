require_relative '../../../helpers/unit/provider/elasticsearch_rest_shared_examples'

describe Puppet::Type.type(:elasticsearch_snapshot_lifecycle_policy).provider(:ruby) do
  let(:example_1) do
    {
      :name                        => 'foobar1',
      :ensure                      => :present,
      :provider                    => :ruby,
      :schedule_time               => '0 30 1 * * ?',
      :repository                  => 'my_repository',
      :snapshot_name               => '<nightly-snap-{now/d}>',
      :config_indices              => ['*'],
      :retention_expire_after      => '30d',
      :retention_min_count         => 5,
      :retention_max_count         => 50

    }
  end

  let(:json_1) do
    {
      'foobar1' => {
        'policy' => {
          'config' => {
            'indices' => ['*']
          },
          'name' => '<nightly-snap-{now/d}>',
          'repository' => 'my_repository',
          'retention' => {
            'expire_after' => '30d',
            'min_count' => 5,
            'max_count' => 50
          },
          'schedule' => '0 30 1 * * ?'
        }
      }
    }
  end

  let(:example_2) do
    {
      :name                   => 'foobar2',
      :ensure                 => :present,
      :provider               => :ruby,
      :schedule_time          => '0 5 3 1 * ?',
      :repository             => 'my_repository_again',
      :snapshot_name          => '<messy-snap-{now/d}>',
      :config_indices         => ['product'],
      :retention_expire_after => '3d',
      :retention_min_count    => 1,
      :retention_max_count    => 5
    }
  end

  let(:json_2) do
    {
      'foobar2' => {
        'policy' => {
          'schedule' => '0 5 3 1 * ?',
          'name' => '<messy-snap-{now/d}>',
          'repository' => 'my_repository_again',
          'config' => {
            'indices' => ['product']
          },
          'retention' => {
            'expire_after' => '3d',
            'min_count' => 1,
            'max_count' => 5
          }
        }
      }
    }
  end

  let(:bare_resource) do
    JSON.dump(
        'policy' => {
          'schedule' => '0 0 * 1 * ?',
          'name' => '<another-snap-{now/d}>',
          'repository' => 'foo_bars',
          'config' => {
            'indices' => ['product']
          },
          'retention' => {
            'expire_after' => '5d',
            'min_count' => 7,
            'max_count' => 10
          }
        }
    )
  end

  let(:resource) { Puppet::Type::Elasticsearch_snapshot_lifecycle_policy.new props }
  let(:provider) { described_class.new resource }
  let(:props) do
    {
      :name                   => 'policy',
      :schedule_time          => '0 0 * 1 * ?',
      :repository             => 'foo_bars',
      :snapshot_name          => '<another-snap-{now/d}>',
      :config_indices         => ['product'],
      :retention_expire_after => '5d',
      :retention_min_count    => 7,
      :retention_max_count    => 10
    }
  end

  include_examples 'REST API', 'slm/policy', '_slm/policy/policy'
end
