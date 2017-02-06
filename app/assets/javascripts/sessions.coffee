	# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->

	$(document).on  'click' , ".resend-confirm-email-button", ->
  	$.ajax "/re_send_to_confirm_email",
  	type: "GET",
  	success: (response) ->
  		$(".email-msg").html(response.message);
  	error: (response) ->
  		$(".email-msg").html(response.message);
