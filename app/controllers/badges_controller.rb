class BadgesController < ApplicationController
	include MarvelUtilities
	include BadgeUtilities

	#Root for the web application
	#Listing of the Superhero data from the Marvel API
	def home
		@characters = get_heros(1)["data"]["results"].last(20) #pagination can be implement like this with offset, selecting last 20 data from the API end point result
		respond_to do |format|
			format.html
		end
	end

	#It fetches & shows all the available badge templates that we can assign to superhero, specified by particular organization
	def index
		@character = params[:character]
		@all_badges_templates = get_badge_templates["data"]
		respond_to do |format|
			format.html
		end
	end

	#To assign a badge to the given specific superhero character
	def assign_badge
		response = assign_badge_to_hero(params[:character], params[:template])

		#This condition is for all the statuses except 201: created, eg: If Badge is already assign to the character and it should show error message that, given badge is already assign to the user.
		if response["data"].present? && (msg = response["data"]["message"]).present?
			flash[:error] = msg || "Something wrong happned on server side!"
		else
      flash[:success] = 'Badge assigned Successfully'
    end
		redirect_to root_path
	end

	#There is one button to get the inromation about the total badges one superhero character has
	def total_badge
		@total_badges = get_total_assigned_bages(params[:character])["data"]
		respond_to do |format|
			format.html
		end
	end

end
