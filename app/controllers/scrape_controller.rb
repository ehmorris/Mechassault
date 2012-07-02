class ScrapeController < ApplicationController
  def show
    agent = Mechanize.new
    root_url = 'http://bnr8ssbp.neu.edu/udcprod8/bwskfcls.p_sel_crse_search'

    # login
    login_page = agent.get(root_url)
    main_menu = login_page.form_with(:name => 'loginform') do |f|
      f.sid = ENV['MYNEU_USERNAME']
      f.PIN = ENV['MYNEU_PASSWORD']
    end.submit

    # reload to get to the semester selection form
    semester_select_page = agent.get(root_url)
    semester_select_form = semester_select_page.forms.last
    #select most recent semester
    semester_select_form.field_with(:dom_id => 'term_input_id').options.first(2).last.tick
    filter_options = semester_select_form.submit

    # course filter option page
    course_options_form = filter_options.forms.last
    #check all subjects
    course_options_form.field_with(:dom_id => 'subj_id').options.each do |o|
      o.tick
    end
    course_info = course_options_form.submit

    @test = course_info
  end
end
