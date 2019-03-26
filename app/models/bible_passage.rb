class BiblePassage < ActiveRecord::Base
  belongs_to :church_ministry
  belongs_to :chapter
end
