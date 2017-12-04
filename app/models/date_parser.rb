class DateParser

  def self.parse_to_db_str (date_str, src_format="%d %B, %Y")
    Date.strptime(date_str, src_format).strftime("%Y-%m-%d")
  end

end