module EventsHelper

	def yes_no_questions
		{
			'mt_society' => "Was anything said about <strong>use of mother tongue in society</strong>?".html_safe,
			'mt_church' => "Was anything said about <strong>use of mother tongue tools in the local churches</strong>?".html_safe,
			'need_society' => "Was anything said about <strong>needs of society</strong>?".html_safe,
			'need_church' => "Was anything said about <strong>needs of the churches</strong>?".html_safe,
			'plan' => "Were any other <strong>hopes, dreams or challenges?</strong> shared?".html_safe,
			'impact' => "Were any other <strong>impact stories</strong> shared?".html_safe
		}
	end
end
