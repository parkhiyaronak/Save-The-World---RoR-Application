module MarvelUtilities

    #Faraday gem is used to make the API reqest
    #Here I have used the concept of pagination and offset, we can implemet pagination gems like kaminari, will_paginate etc here!
    def get_heros(page)
      page = page.presence || 1
      public_key = Rails.application.credentials.marvel[:public_key]
      connection = Faraday.new(ENV['MARVEL_BASE_URL']) do |f|
        f.response :logger
        f.adapter Faraday.default_adapter
      end
      offset = (page-1)*100
      ts = Time.now.to_i.to_s
      params = {apikey: public_key,ts: ts, hash: md5_hash(ts, public_key), limit: 100, offset: offset}
      response = connection.get("/v1/public/characters") do |request|
        request.params = params
      end
      JSON.parse(response.body)
    end

    private
    #Calculating md5 has, as Marvel API required this parameter while hiting the end point
    def md5_hash(ts, public_key)
      private_key = Rails.application.credentials.marvel[:private_key]
      Digest::MD5.hexdigest(ts + private_key + public_key)
    end
end