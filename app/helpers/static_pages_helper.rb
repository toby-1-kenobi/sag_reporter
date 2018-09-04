module StaticPagesHelper
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
