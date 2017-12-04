module UsersHelper

  # get a link to a user by name
  # don't mention the user name if the logged in user
  # doesn't have high-sensitivity access
  # assume there's a logged in user.
  def user_link(user)
    anchor_text = (logged_in_user.trusted? or logged_in_user?(user)) ? user.name : "user ##{user.id}"
    link_to anchor_text, user_path(user)
  end

end
