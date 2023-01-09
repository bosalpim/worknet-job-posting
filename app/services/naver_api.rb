# https://api.ncloud-docs.com/docs/ai-naver-mapsreversegeocoding-gc
class NaverApi
  DEFAULT_LAT = 37.555042
  DEFAULT_LNG = 126.9769233

  def self.addresses_from_coords(lat, lng)
    api_response = reverse_geo_coding(lat, lng) rescue nil

    return nil if api_response.nil?

    addr = api_response.find { |addr| addr['name'] == 'addr' }
    road_addr = api_response.find { |addr| addr['name'] == 'roadaddr' }

    {
      address: merge_address(addr, :address),
      road_address: merge_address(road_addr, :road_address),
      rough_address: rough_address(addr),
    }
  end

  def self.coords_from_address(address)
    api_response = geo_coding(address) rescue nil

    return { lat: DEFAULT_LAT, lng: DEFAULT_LNG } if api_response.nil?

    { lat: api_response.first['y'], lng: api_response.first['x'] }
  end

  def self.reverse_geo_coding(lat, lng)
    coordinates = [lng, lat].join(',')

    conn =
      Faraday.new(
        url: 'https://naveropenapi.apigw.ntruss.com',
        headers: {
          'X-NCP-APIGW-API-KEY-ID' =>
            ENV['NAVER_API_KEY_ID'],
          'X-NCP-APIGW-API-KEY' => ENV['NAVER_API_KEY'],
        },
        ) do |f|
        f.response :json
        f.adapter :net_http
      end

    response =
      conn.get(
        '/map-reversegeocode/v2/gc',
        { coords: coordinates, orders: 'addr,roadaddr', output: 'json' },
        )

    return nil if response.body['results'].blank?

    response.body['results']
  end

  def self.geo_coding(address)
    conn =
      Faraday.new(
        url: 'https://naveropenapi.apigw.ntruss.com',
        headers: {
          'X-NCP-APIGW-API-KEY-ID' =>
            ENV['NAVER_API_KEY_ID'],
          'X-NCP-APIGW-API-KEY' => ENV['NAVER_API_KEY'],
          :'Accept' => 'application/json',
        },
        ) do |f|
        f.response :json
        f.adapter :net_http
      end

    response = conn.get('/map-geocode/v2/geocode', { query: address })

    puts response.body

    return nil if response.body['addresses'].blank?

    response.body['addresses']
  end

  private

  def self.merge_address(structure, type)
    return nil if structure.nil?

    variation = [*1..4]

    addr_arr = variation.map { |v| structure.dig('region', "area#{v}", 'name') }

    addr_arr << structure.dig('land', 'name') if type == :road_address

    addr_arr << structure.dig('land', 'number1')

    addr_arr << '-' if !structure.dig('land', 'number2').blank?

    addr_arr << structure.dig('land', 'number2')

    # Too much details
    # addr_arr +=
    #   variation.map { |v| structure.dig('land', "addition#{v}", 'value') }

    addr_arr.join(' ').gsub(/ {2,}/, ' ').gsub(/ - /, '-').strip
  end

  def self.rough_address(structure)
    variation = [*1..3]

    addr_arr = variation.map { |v| structure.dig('region', "area#{v}", 'name') }

    addr_arr.join(' ').gsub(/ {2,}/, ' ').gsub(/ - /, '-').strip
  end
end

# Response Sample
# {"status"=>{"code"=>0, "name"=>"ok", "message"=>"done"},
#  "results"=>
#   [{"name"=>"addr",
#     "code"=>{"id"=>"4111514100", "type"=>"L", "mappingId"=>"02115141"},
#     "region"=>
#      {"area0"=>{"name"=>"kr", "coords"=>{"center"=>{"crs"=>"", "x"=>0.0, "y"=>0.0}}},
#       "area1"=>{"name"=>"경기도", "coords"=>{"center"=>{"crs"=>"EPSG:4326", "x"=>127.550802, "y"=>37.4363177}}, "alias"=>"경기"},
#       "area2"=>{"name"=>"수원시 팔달구", "coords"=>{"center"=>{"crs"=>"EPSG:4326", "x"=>127.0200976, "y"=>37.2825695}}},
#       "area3"=>{"name"=>"인계동", "coords"=>{"center"=>{"crs"=>"EPSG:4326", "x"=>127.0301429, "y"=>37.2680521}}},
#       "area4"=>{"name"=>"", "coords"=>{"center"=>{"crs"=>"", "x"=>0.0, "y"=>0.0}}}},
#     "land"=>
#      {"type"=>"1",
#       "number1"=>"1119",
#       "number2"=>"",
#       "addition0"=>{"type"=>"", "value"=>""},
#       "addition1"=>{"type"=>"", "value"=>""},
#       "addition2"=>{"type"=>"", "value"=>""},
#       "addition3"=>{"type"=>"", "value"=>""},
#       "addition4"=>{"type"=>"", "value"=>""},
#       "coords"=>{"center"=>{"crs"=>"", "x"=>0.0, "y"=>0.0}}}},
#    {"name"=>"admcode",
#     "code"=>{"id"=>"4111573000", "type"=>"S", "mappingId"=>"02115141"},
#     "region"=>
#      {"area0"=>{"name"=>"kr", "coords"=>{"center"=>{"crs"=>"", "x"=>0.0, "y"=>0.0}}},
#       "area1"=>{"name"=>"경기도", "coords"=>{"center"=>{"crs"=>"EPSG:4326", "x"=>127.550802, "y"=>37.4363177}}, "alias"=>"경기"},
#       "area2"=>{"name"=>"수원시 팔달구", "coords"=>{"center"=>{"crs"=>"EPSG:4326", "x"=>127.0200976, "y"=>37.2825695}}},
#       "area3"=>{"name"=>"인계동", "coords"=>{"center"=>{"crs"=>"EPSG:4326", "x"=>127.0301429, "y"=>37.2680521}}},
#       "area4"=>{"name"=>"", "coords"=>{"center"=>{"crs"=>"", "x"=>0.0, "y"=>0.0}}}}},
#    {"name"=>"roadaddr",
#     "code"=>{"id"=>"4111514100", "type"=>"L", "mappingId"=>"02115141"},
#     "region"=>
#      {"area0"=>{"name"=>"kr", "coords"=>{"center"=>{"crs"=>"", "x"=>0.0, "y"=>0.0}}},
#       "area1"=>{"name"=>"경기도", "coords"=>{"center"=>{"crs"=>"EPSG:4326", "x"=>127.550802, "y"=>37.4363177}}, "alias"=>"경기"},
#       "area2"=>{"name"=>"수원시 팔달구", "coords"=>{"center"=>{"crs"=>"EPSG:4326", "x"=>127.0200976, "y"=>37.2825695}}},
#       "area3"=>{"name"=>"인계동", "coords"=>{"center"=>{"crs"=>"EPSG:4326", "x"=>127.0301429, "y"=>37.2680521}}},
#       "area4"=>{"name"=>"", "coords"=>{"center"=>{"crs"=>"", "x"=>0.0, "y"=>0.0}}}},
#     "land"=>
#      {"type"=>"",
#       "number1"=>"48",
#       "number2"=>"21",
#       "addition0"=>{"type"=>"building", "value"=>"인계샤르망오피스텔"},
#       "addition1"=>{"type"=>"zipcode", "value"=>"16488"},
#       "addition2"=>{"type"=>"roadGroupCode", "value"=>"411154331157"},
#       "addition3"=>{"type"=>"", "value"=>""},
#       "addition4"=>{"type"=>"", "value"=>""},
#       "name"=>"인계로166번길",
#       "coords"=>{"center"=>{"crs"=>"", "x"=>0.0, "y"=>0.0}}}}]}
