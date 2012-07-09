class Scraper < ActiveRecord::Base

  def self.scrape_dat
    require 'mechanize'
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

    # store all html data
    courses_html = course_info.search('table.datadisplaytable tr')

    return courses_html
  end

  def self.parse_dat
    # generate hash from parsed html data
    courses_hash = self.scrape_dat.map do |row|
      # convert closed field to a boolean
      closed = false
      closed = true if row.search('>:nth-child(1)').inner_text == 'C'

      # gather all class data
      crn        = row.search('>:nth-child(2)').inner_text
      subject    = row.search('>:nth-child(3)').inner_text
      coursenum  = row.search('>:nth-child(4)').inner_text
      section    = row.search('>:nth-child(5)').inner_text
      campus     = row.search('>:nth-child(6)').inner_text
      credits    = row.search('>:nth-child(7)').inner_text
      title      = row.search('>:nth-child(8)').inner_text
      days       = row.search('>:nth-child(9)').inner_text
      time       = row.search('>:nth-child(10)').inner_text
      capacity   = row.search('>:nth-child(11)').inner_text
      actual     = row.search('>:nth-child(12)').inner_text
      remaining  = row.search('>:nth-child(13)').inner_text
      instructor = row.search('>:nth-child(14)').inner_text
      date       = row.search('>:nth-child(15)').inner_text
      location   = row.search('>:nth-child(16)').inner_text
      attribute  = row.search('>:nth-child(17)').inner_text

      # determine if the current row is paired with the previous row
      # i.e. when a class has different times on different days,
      # or when a class only occurs twice and both dates are listed
      pair = false
      pair = true if crn.blank? and !days.blank? and !time.blank? and capacity.blank?

      # make sure this row is a class data row
      # check to make sure the CRN field has a CRN
      # if the row was tagged as a pair, get its reduced dataset
      if crn.to_i > 0
        # put data into a hash
        {
          :closed     => closed,
          :crn        => crn,
          :subject    => subject,
          :coursenum  => coursenum,
          :section    => section,
          :campus     => campus,
          :credits    => credits,
          :title      => title,
          :days       => days,
          :time       => time,
          :capacity   => capacity,
          :actual     => actual,
          :remaining  => remaining,
          :instructor => instructor,
          :date       => date,
          :location   => location,
          :attribute  => attribute
        }
      elsif pair
        {
          :pair       => pair,
          :days       => days,
          :time       => time,
          :instructor => instructor,
          :date       => date,
          :location   => location,
          :attribute  => attribute
        }
      end
    end

    # squash pairs together, remove nil entries, determine type of pairing
    courses_hash.each.with_index do |course, e|
      # there will be some nil entries in courses_hash
      if course
        if course[:pair]
          pair_type = 'seminar'
          pair_type = 'classtime' if course[:date] == courses_hash[e-1][:date]

          course[:pair_type] = pair_type

          # replace previous entry with combo of this and previous entry
          courses_hash[e-1][:paired_entry] = course

          # remove this entry after squashing it
          courses_hash.delete(course)
        end
      end
    end

    return courses_hash
  end

  # Throws courses into database
  def self.save_dat
    # TODO: write this code
  end
end
