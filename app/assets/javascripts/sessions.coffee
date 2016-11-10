# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
	$('#btn_login').on 'click' , ->
		$.ajax "/verify_otp",
			type: "POST",
			data: "otp_code="+$("#session_otp_code").val(),
			success: (response) ->
				if(response.success == true)
					$("#otp_form").submit();
				else
					$(".teal").hide();
					$(".otp_msg").show().html(response.message);
			error: (response) ->
				$(".otp_msg").html(response);

	$(document).on	'click' , ".resend_otp", ->
		$.ajax "/resend_otp",
			type: "GET",
			success: (response) ->
				console.log(response.otp_code);
				$(".teal").hide();
				$(".otp_msg").show().html(response.message);
			error: (response) ->
				$(".otp_msg").html(response.message);
