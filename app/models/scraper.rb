class Scraper < ActiveRecord::Base
  require 'mechanize'

  # Scrapes MyNEU's course pages
  def self.scrape_dat
    agent = Mechanize.new

    root_url = 'http://bnr8ssbp.neu.edu/udcprod8/bwskfcls.p_sel_crse_search'
    # Fall 2012 semester
    semester_value = '201310'

    # login
    login_page = agent.get(root_url)
    main_menu = login_page.form_with(:name => 'loginform') do |f|
      f.sid = ENV['MYNEU_USERNAME']
      f.PIN = ENV['MYNEU_PASSWORD']
    end.submit

    # reload to get to the semester selection form
    semester_select_page = agent.get(root_url)
    semester_select_form = semester_select_page.forms.last
    #select fall 2012 semester
    semester_select_box = semester_select_form.field_with(:dom_id => 'term_input_id')
    .option_with(:value => semester_value).tick
    filter_options = semester_select_form.submit

    # course filter option page
    course_options_form = filter_options.forms.last
    #check all subjects
    course_options_form.field_with(:dom_id => 'subj_id').options.each do |o|
      o.tick
      break # remove to fetch all classes
    end
    course_info = course_options_form.submit

    courses_html = course_info.search('table.datadisplaytable tr')

    courses_json = courses_html.map do |row|
      # make sure this row is a class data row
      #if row.children.count > 2 and row.search('> td.dddefault').count
      {
        :closed     => row.search('>:nth-child(1)').inner_text,
        :crn        => row.search('>:nth-child(2)').inner_text,
        :subject    => row.search('>:nth-child(3)').inner_text,
        :coursenum  => row.search('>:nth-child(4)').inner_text,
        :section    => row.search('>:nth-child(5)').inner_text,
        :campus     => row.search('>:nth-child(6)').inner_text
      }
      #end
    end.to_json

    #courses_json = courses_html.last.search('>:nth-child(1)').inner_text

    courses_json
  end

  # Throws courses into database
  def self.throw_it_on_the_ground
    # TODO: write this code
  end
end
