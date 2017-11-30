class StaticPagesController < ApplicationController

  before_action :require_login, only: [:tasks, :home, :about]

  def home
    @links = [
      {
          condition: true,
          path: new_report_path,
          text: 'Report impact stories',
          icon: 'create',
          lcr_icon: 'lcr-icon-write-report',
          colour: 'blue',
          category: 'report'
      },
      {
          condition: true,
          path: 'https://docs.google.com/forms/d/1NQHDwomtgh2kVmx1BZRzDuv1lv__SaVzAHfBOH_JlXU/viewform?c=0&w=1',
          text: 'Report on a workshop',
          icon: 'create',
          lcr_icon: 'lcr-icon-workshop',
          colour: 'teal',
          category: 'report'
      },
      {
          condition: true,
          path: 'https://www.surveymonkey.com/r/R989HM9',
          text: 'Report on movement building',
          icon: 'create',
          lcr_icon: 'lcr-icon-build',
          colour: 'yellow',
          category: 'report'
      },
      # {
      #     condition: true,
      #     path: events_new_path,
      #     text: Translation.get_string('report_event', logged_in_user),
      #     icon: 'event',
      #     colour: 'cyan',
      #     category: 'report'
      # },
      {
          condition: true,
          path: new_mt_resource_path,
          text: 'Report on a completed resource',
          icon: 'build',
          colour: 'brown',
          category: 'report'
      },
      {
          condition: logged_in_user.reports.any?,
          path: my_reports_path,
          text: 'My reports',
          icon: 'insert_drive_file',
          category: 'report'
      },
      # {
      #     condition: true,
      #     path: report_numbers_path,
      #     text: 'Report numbers for the month',
      #     icon: 'assessment',
      #     colour: 'green',
      #     category: 'report'
      # },
      {
          condition: true,
          path: tag_impact_reports_path,
          text: 'Tag impact reports',
          icon: 'label',
          lcr_icon: 'lcr-icon-tag',
          colour: 'red',
          category: 'progress'
      },
      {
          condition: true,
          path: select_to_assess_path,
          text: 'Assess progress marker levels',
          icon: 'check_circle',
          colour: 'purple',
          category: 'progress'
      },
      # {
      #     condition: (logged_in_user.national?'),
      #     path: outputs_path,
      #     text: 'View output totals',
      #     icon: 'tab',
      #     colour: 'pink',
      #     category: 'progress'
      # },
      {
          condition: true,
          path: outcomes_path,
          text: 'View outcome transformation progress',
          icon: 'tab',
          colour: 'indigo',
          category: 'progress'
      },
      {
          condition: (true),
          path: reports_path,
          text: 'All reports',
          icon: 'dashboard',
          colour: 'amber',
          category: 'report'
      },
      {
          condition: (logged_in_user.admin?),
          path: users_path,
          text: 'All users',
          icon: 'people',
          colour: 'lime',
          category: 'other'
      },
      # {
      #     condition: (logged_in_user.national?),
      #     path: languages_path,
      #     text: 'View all languages',
      #     icon: 'language',
      #     colour: 'orange',
      #     category: 'other'
      # },
      # {
      #     condition: (true),
      #     path: topics_path,
      #     text: 'View all outcome areas',
      #     icon: 'local_offer',
      #     colour: 'light-green',
      #     category: 'other'
      # },
      {
          condition: (logged_in_user.national?),
          path: overview_path,
          text: 'Overview',
          icon: 'pageview',
          colour: 'grey',
          category: 'other'
      },
      {
          condition: (logged_in_user.national?),
          path: transformation_path,
          text: 'Transformation',
          icon: 'change_history',
          colour: 'light-blue',
          category: 'other'
      },
      {
          condition: (logged_in_user.curated_states.any? or logged_in_user.national_curator?),
          path: curate_edits_path,
          text: 'Curate',
          icon: 'done_all',
          colour: 'deep-orange',
          category: 'other'
      },
      {
          condition: logged_in_user.edits.any?,
          path: my_edits_path,
          text: 'My edits',
          icon: 'comment',
          colour: 'orange',
          category: 'other'
      }
    ]
  end

  def about
    @outcome_areas = Topic.all.order(:number)
  end

  def tasks
    @links = [
        {
            condition: true,
            path: new_report_path,
            text: 'Report impact stories',
            icon: 'create',
            lcr_icon: 'lcr-icon-write-report',
            colour: 'blue',
            category: 'report'
        },
        {
            condition: true,
            path: 'https://docs.google.com/forms/d/1NQHDwomtgh2kVmx1BZRzDuv1lv__SaVzAHfBOH_JlXU/viewform?c=0&w=1',
            text: 'Report on a workshop',
            icon: 'create',
            lcr_icon: 'lcr-icon-workshop',
            colour: 'teal',
            category: 'report'
        },
        {
            condition: true,
            path: 'https://www.surveymonkey.com/r/R989HM9',
            text: 'Report on movement building',
            icon: 'create',
            lcr_icon: 'lcr-icon-build',
            colour: 'yellow',
            category: 'report'
        },
        # {
        #     condition: true,
        #     path: events_new_path,
        #     text: Translation.get_string('report_event', logged_in_user),
        #     icon: 'event',
        #     colour: 'cyan',
        #     category: 'report'
        # },
        {
            condition: true,
            path: new_mt_resource_path,
            text: 'Report on a completed resource',
            icon: 'build',
            colour: 'brown',
            category: 'report'
        },
        {
            condition: logged_in_user.reports.any?,
            path: my_reports_path,
            text: 'My reports',
            icon: 'insert_drive_file',
            category: 'report'
        },
        # {
        #     condition: true,
        #     path: report_numbers_path,
        #     text: 'Report numbers for the month',
        #     icon: 'assessment',
        #     colour: 'green',
        #     category: 'report'
        # },
        {
            condition: true,
            path: tag_impact_reports_path,
            text: 'Tag impact reports',
            icon: 'label',
            lcr_icon: 'lcr-icon-tag',
            colour: 'red',
            category: 'progress'
        },
        {
            condition: true,
            path: select_to_assess_path,
            text: 'Assess progress marker levels',
            icon: 'check_circle',
            colour: 'purple',
            category: 'progress'
        },
        # {
        #     condition: (logged_in_user.national?'),
        #     path: outputs_path,
        #     text: 'View output totals',
        #     icon: 'tab',
        #     colour: 'pink',
        #     category: 'progress'
        # },
        {
            condition: true,
            path: outcomes_path,
            text: 'View outcome transformation progress',
            icon: 'tab',
            colour: 'indigo',
            category: 'progress'
        },
        {
            condition: (true),
            path: reports_path,
            text: 'All reports',
            icon: 'dashboard',
            colour: 'amber',
            category: 'report'
        },
        {
            condition: (logged_in_user.admin?),
            path: users_path,
            text: 'All users',
            icon: 'people',
            colour: 'lime',
            category: 'other'
        },
        # {
        #     condition: (logged_in_user.national?),
        #     path: languages_path,
        #     text: 'View all languages',
        #     icon: 'language',
        #     colour: 'orange',
        #     category: 'other'
        # },
        # {
        #     condition: (true),
        #     path: topics_path,
        #     text: 'View all outcome areas',
        #     icon: 'local_offer',
        #     colour: 'light-green',
        #     category: 'other'
        # },
        {
            condition: (logged_in_user.national?),
            path: overview_path,
            text: 'Overview',
            icon: 'pageview',
            colour: 'grey',
            category: 'other'
        },
        {
            condition: (logged_in_user.national?),
            path: transformation_path,
            text: 'Transformation',
            icon: 'change_history',
            colour: 'light-blue',
            category: 'other'
        },
        {
            condition: (logged_in_user.curated_states.any? or logged_in_user.national_curator?),
            path: curate_edits_path,
            text: 'Curate',
            icon: 'done_all',
            colour: 'deep-orange',
            category: 'other'
        },
        {
            condition: logged_in_user.edits.any?,
            path: my_edits_path,
            text: 'My edits',
            icon: 'comment',
            colour: 'orange',
            category: 'other'
        }
    ]
  end

  def whatsapp_link
    @supress_header = true
    @supress_footer = true
  end

end
