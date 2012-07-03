class ScraperController < ApplicationController
  def show
    @test = Scraper.scrape_dat
  end
end
