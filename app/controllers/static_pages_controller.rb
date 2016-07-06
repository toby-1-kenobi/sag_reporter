class StaticPagesController < ApplicationController

  before_action :require_login, only: [:home]

  def home
    @links = [
        {
            permission: 'create_report',
            path: new_report_path,
            text: 'Report impact stories',
            icon: 'create',
            lcr_icon: 'lcr-icon-write-report',
            colour: 'blue',
            category: 'weekly'
        },
        {
            permission: 'create_report',
            path: 'https://docs.google.com/forms/d/1NQHDwomtgh2kVmx1BZRzDuv1lv__SaVzAHfBOH_JlXU/viewform?c=0&w=1',
            text: 'Report on a workshop',
            icon: 'create',
            lcr_icon: 'lcr-icon-workshop',
            colour: 'teal',
            category: 'other'
        },
        {
            permission: 'create_report',
            path: 'https://www.surveymonkey.com/r/R989HM9',
            text: 'Report on movement building',
            icon: 'create',
            lcr_icon: 'lcr-icon-build',
            colour: 'yellow',
            category: 'weekly'
        },
        {
            permission: 'create_event',
            path: events_new_path,
            text: Translation.get_string('report_event', logged_in_user),
            icon: 'event',
            colour: 'cyan',
            category: 'other'
        },
        {
            permission: 'report_numbers',
            path: new_mt_resource_path,
            text: 'Report on a completed resource',
            icon: 'build',
            colour: 'brown',
            category: 'monthly'
        },
        {
            permission: 'report_numbers',
            path: report_numbers_path,
            text: 'Report numbers for the month',
            icon: 'assessment',
            colour: 'green',
            category: 'monthly'
        },
        {
            permission: 'tag_report',
            path: tag_impact_reports_path,
            text: 'Tag impact reports',
            icon: 'label',
            lcr_icon: 'lcr-icon-tag',
            colour: 'red',
            category: 'weekly'
        },
        {
            permission: 'evaluate_progress',
            path: select_to_assess_path,
            text: 'Assess progress marker levels',
            icon: 'check_circle',
            colour: 'purple',
            category: 'monthly'
        },
        {
            permission: 'view_output_totals',
            path: outputs_path,
            text: 'View output totals',
            icon: 'tab',
            colour: 'pink',
            category: 'other'
        },
        {
            permission: 'view_outcome_totals',
            path: outcomes_path,
            text: 'View outcome progress',
            icon: 'tab',
            colour: 'indigo',
            category: 'other'
        },
        {
            permission: 'view_all_reports',
            path: reports_path,
            text: 'View all reports',
            icon: 'dashboard',
            colour: 'amber',
            category: 'other'
        },
        {
            permission: 'view_all_users',
            path: users_path,
            text: 'View all users',
            icon: 'people',
            colour: 'lime',
            category: 'other'
        },
        {
            permission: 'view_roles',
            path: roles_path,
            text: 'View roles and permissions',
            icon: 'people_outline',
            colour: 'light-blue',
            category: 'other'
        },
        {
            permission: 'view_all_languages',
            path: languages_path,
            text: 'View all languages',
            icon: 'language',
            colour: 'orange',
            category: 'other'
        },
        {
            permission: 'view_all_topics',
            path: topics_path,
            text: 'View all outcome areas',
            icon: 'local_offer',
            colour: 'light-green',
            category: 'other'
        },
        {
            permission: 'view_all_languages',
            path: overview_path,
            text: 'Overview',
            icon: 'pageview',
            colour: 'grey',
            category: 'other'
        },
        {
            permission: 'view_all_languages',
            path: transformation_path,
            text: 'Transformation',
            icon: 'change_history',
            colour: 'light-blue',
            category: 'other'
        }
    ]
  end

  def whatsapp_link
    @supress_header = true
    @supress_footer = true
  end

end
