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
end
