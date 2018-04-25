class StaticPagesController < ApplicationController
  include UsersHelper
  before_action :require_login, only: [:tasks, :home, :about]

  def about
    @outcome_areas = Topic.all.order(:number)
  end

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
        {
            condition: (logged_in_user.trusted? or logged_in_user.reports.active.any?),
            path: tag_impact_reports_path,
            text: 'Tag impact reports',
            icon: 'label',
            lcr_icon: 'lcr-icon-tag',
            colour: 'red',
            category: 'progress'
        },
        {
            condition: (logged_in_user.trusted?),
            path: select_to_assess_path,
            text: 'Assess progress marker levels',
            icon: 'check_circle',
            colour: 'purple',
            category: 'progress'
        },
        {
            condition: true,
            path: outcomes_path,
            text: 'Outcome progress',
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
        {
            condition: (logged_in_user.admin?),
            path: new_user_path,
            text: 'New user',
            icon: 'person_add',
            colour: 'orange',
            category: 'other'
        },
        {
            condition: (logged_in_user.admin?),
            category: 'resetpassword',
            users: reset_pwd_users()
        },

        {
            condition: (logged_in_user.admin?),
            path: projects_path,
            text: 'Projects',
            icon: 'group_work',
            colour: 'orange',
            category: 'other'
        },
        {
            condition: (logged_in_user.national?),
            path: transformation_path,
            text: 'Transformation',
            icon: 'change_history',
            colour: 'light-blue',
            category: 'progress'
        }
    ]
  end

  def whatsapp_link
    @supress_header = true
    @supress_footer = true
  end

end
