
def get_url

  urls = { 
    'URL_MASTER' => 'http://s3-eu-west-1.amazonaws.com/build-eu.elasticsearch.org/origin/master/nightly/JDK7/elasticsearch-latest-SNAPSHOT.$EXT$',
    'URL_1x' => 'http://s3-eu-west-1.amazonaws.com/build-eu.elasticsearch.org/origin/1.x/nightly/JDK7/elasticsearch-latest-SNAPSHOT.$EXT$',
    'URL_16' => 'http://s3-eu-west-1.amazonaws.com/build.eu-west-1.elastic.co/origin/1.6/nightly/JDK7/elasticsearch-latest-SNAPSHOT.$EXT$',
    'URL_15' => 'http://s3-eu-west-1.amazonaws.com/build.eu-west-1.elastic.co/origin/1.5/nightly/JDK7/elasticsearch-latest-SNAPSHOT.$EXT$',
    'URL_14' => 'http://s3-eu-west-1.amazonaws.com/build-eu.elasticsearch.org/origin/1.4/nightly/JDK7/elasticsearch-latest-SNAPSHOT.$EXT$',
    'URL_13' => 'http://s3-eu-west-1.amazonaws.com/build-eu.elasticsearch.org/origin/1.3/nightly/JDK7/elasticsearch-latest-SNAPSHOT.$EXT$',
    'URL_12' => 'http://s3-eu-west-1.amazonaws.com/build-eu.elasticsearch.org/origin/1.2/nightly/JDK7/elasticsearch-latest-SNAPSHOT.$EXT$',
    'URL_11' => 'http://s3-eu-west-1.amazonaws.com/build-eu.elasticsearch.org/origin/1.1/nightly/JDK7/elasticsearch-latest-SNAPSHOT.$EXT$',
    'URL_10' => 'http://s3-us-west-2.amazonaws.com/build.elasticsearch.org/origin/1.0/nightly/JDK6/elasticsearch-latest-SNAPSHOT.$EXT$',
    'URL_TAGS' => 'http://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-$VERSION$.$EXT$'
  }

  es_version = ENV['ES_VERSION']

  if es_version =~ /_nightly$/
    # We are testing a snapshot of a branch
    ver = es_version.split('_')[0].tr('.', '')
    url = urls["URL_#{ver}"]
  else
    # we are testing a released version
    url = urls["URL_TAGS"].gsub('$VERSION$', es_version)
  end

  return url

end
