class Chapter < ActiveRecord::Base

  belongs_to :book
  has_many :translation_progresses, dependent: :destroy
  has_many :translation_projects, through: :translation_progresses

  validates :book, presence: true
  validates :number, presence: true, inclusion: 1..150
  validates :verses, presence: true, inclusion: 1..176

  def self.to_ref(abbr = false)
    bookname = abbr ? :abbreviation : :name
    all_books = Book.all.pluck_to_struct(:id, bookname, :number).map{ |b| [b.id, b] }.to_h
    chaps = pluck_to_struct(:book_id, :number).sort_by{ |ch| [all_books[ch.book_id].number, ch.number] }
    first = chaps.shift
    ref = [{book: first.book_id, chapters:[[first.number, first.number]]}]
    chaps.each do |chap|
      if chap.book_id == ref.last[:book]
        if chap.number == ref.last[:chapters].last[1] + 1
          ref.last[:chapters].last[1] += 1
        else
          ref.last[:chapters] << [chap.number, chap.number]
        end
      else
        ref << {book: chap.book_id, chapters:[[chap.number, chap.number]]}
      end
    end
    ref.map{ |r| "#{all_books[r[:book]].send(bookname)} #{r[:chapters].map{ |a, b| a == b ? a.to_s : "#{a}-#{b}" }.join(', ') }" }.join('; ')
  end

end
