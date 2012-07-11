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

    courses_hash = courses_html.map do |row|
      # make sure this row is a class data row
      # check to make sure the CRN field has a CRN
      if row.search('>:nth-child(2)').inner_text.to_i.is_a? Integer and
         row.search('>:nth-child(2)').inner_text.to_i > 0
        if row.search('>:nth-child(1)').inner_text == 'C'
          closed = true
        else
          closed = false
        end
        {
          :closed     => closed,
          :crn        => row.search('>:nth-child(2)').inner_text,
          :subject    => row.search('>:nth-child(3)').inner_text,
          :coursenum  => row.search('>:nth-child(4)').inner_text,
          :section    => row.search('>:nth-child(5)').inner_text,
          :campus     => row.search('>:nth-child(6)').inner_text,
          :credits    => row.search('>:nth-child(7)').inner_text,
          :title      => row.search('>:nth-child(8)').inner_text,
          :days       => row.search('>:nth-child(9)').inner_text,
          :time       => row.search('>:nth-child(10)').inner_text,
          :capacity   => row.search('>:nth-child(11)').inner_text,
          :actual     => row.search('>:nth-child(12)').inner_text,
          :remaining  => row.search('>:nth-child(13)').inner_text,
          :instructor => row.search('>:nth-child(14)').inner_text,
          :date       => row.search('>:nth-child(15)').inner_text,
          :location   => row.search('>:nth-child(16)').inner_text,
          :attribute  => row.search('>:nth-child(17)').inner_text
        }
      end
    end

    #courses_json = courses_html.last.search('>:nth-child(1)').inner_text

    courses_hash
  end

  # Throws courses into database
  def self.throw_it_on_the_ground
    # TODO: write this code
  end
end
