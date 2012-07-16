class ScraperController < ApplicationController
  def show
    @test = Scraper.parse_dat
  end
end
