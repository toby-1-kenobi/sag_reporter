module StaticPagesHelper

  def landing_page_links
    [
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
            condition: (logged_in_user.national?),
            path: transformation_path,
            text: 'Transformation',
            icon: 'change_history',
            colour: 'light-blue',
            category: 'progress'
        }
    ]
  end

  def dialog_titles
    {
        'report' => 'Enter and View Reports',
        'progress' => 'Update and Assess Progress',
        'other' => 'Admin Tasks'
    }
  end

  def get_edit_count
    count = Edit.pending.for_curating(logged_in_user).count
    if logged_in_user.national_curator?
      count += Edit.pending_national_approval.count
    end
    if logged_in_user.forward_planning_curator?
      count += Edit.pending_forward_planning_approval.count
    end
    count
  end

  # how many user registrations are awaiting the logged in users approval
  def get_registrations_count
    count = 0
    if logged_in_user.zone_admin?
      count += User.unapproved. # counting unapproved registrations
          in_zones(logged_in_user.zones). # sharing at least one zone with the logged in user
          to_a.select{ |u| # filter out all registrations that are already approved in this users zones
            ( # getting the zones yet to be approved, intersect with the logged in users zones
              (u.zones - u.registration_approved_zones) & logged_in_user.zones
            ).any? # if there are any in that intersect keep this user in the count
          }.count
    end
    if logged_in_user.lci_board_member?
      count += User.zone_approved.in_zones(logged_in_user.zones).count
    end
    count
  end

end
