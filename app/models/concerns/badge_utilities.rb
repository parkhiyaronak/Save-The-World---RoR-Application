module BadgeUtilities

  #For all the credentials ENV variables are used (ORGANIZATION_ID, BASE_URL)
  #For all the secret keys, Rails 5.2 credentials API feature has been used with the help of two files only
  #   1. config/credentials.yml.enc
  #   2. config/master.key
  #In Rails v5.2, the file where you are going to store all your private credentials is config/credentials.yml.enc.
  #As it’s extension suggests, this file is going to be encrypted - so you won’t be able to read what’s inside of it - unless you have the proper master key to decrypt it.

  #Faraday gem is used here in order to make the HTTP requests on the APIs
  
  #There is a scope of refactoring here, where we can define one private method which can do all the same repetitive tasks like, setting up headers, logger, adapter  

  #this method is for getting all the available template for the given organization
  def get_badge_templates(extra_params =  nil)
    headers = { "Content-Type" => 'application/json', "Authorization" => "Basic #{token}" } #Seting headers
    connection = Faraday.new(ENV['BASE_URL']) do |f|
      f.response :logger
      f.adapter Faraday.default_adapter
    end
    response = connection.get("/v1/organizations/#{ENV['ORGANIZATION_ID']}/badge_templates") do |request|
      request.headers = headers
    end
    JSON.parse(response.body)
  end


  #this methos is used for assigning the badge(with the hekp of temlate_id) to the specific hero (one of Marvel chartecter from the home listing)
  def assign_badge_to_hero(character_id, template_id)
    headers = { "Content-Type" => 'application/json', "Authorization" => "Basic #{token}" }
    connection = Faraday.new(ENV['BASE_URL']) do |f|
      f.response :logger
      f.adapter Faraday.default_adapter
    end
    
    #Setting the the required body params
    body = {
      recipient_email: "#{character_id}@test.com", #Using parameter character_id here, in order to generate the hero specific dummy emails.
      badge_template_id: template_id || 'fea7986e-079e-4917-b671-90fd68aad4de', #Template id passed from the index page is used here
      issued_at:  "2020-04-01 09:41:00 -0500",
      issued_to_first_name: character_id || "Test First name",
      issued_to_last_name:  "Test Last name"
    }
    response = connection.post("/v1/organizations/#{ENV['ORGANIZATION_ID']}/badges") do |request|
      request.headers = headers  
      request.body = body.to_json
    end
    JSON.parse(response.body)
  end

  #It will show all the badges that are specific to individual character hero
  def get_total_assigned_bages(character_id)
    headers = { "Content-Type" => 'application/json', "Authorization" => "Basic #{token}" } #Seting headers
    connection = Faraday.new(ENV['BASE_URL']) do |f|
      f.response :logger
      f.adapter Faraday.default_adapter
    end
    #As while issuing a badge to specific character using his character_id in email parameter, the same thing is used here in order to filterout the data based on the character specific emails
    params = {filter: "recipient_email::#{character_id}@test.com"} 
    response = connection.get("/v1/organizations/#{ENV['ORGANIZATION_ID']}/badges?") do |request|
      request.headers = headers
      request.params = params
    end
    JSON.parse(response.body)    
  end

  private
    def token
      Base64.strict_encode64("#{Rails.application.credentials.credly[:auth_token]}:")
    end
end 