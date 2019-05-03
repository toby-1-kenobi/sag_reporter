class BiblePassage < ActiveRecord::Base

  has_paper_trail

  belongs_to :church_ministry
  belongs_to :chapter

  validates :church_ministry, presence: true
  validates :chapter, presence: true
  validates :month, presence: true, format: { with: /\A[2-9]\d{3}-(0|1)[0-9]\z/, message: "should be in the format 'YYYY-MM'"}
  validates :verse, presence: true, :numericality => { greater_than: 0 }
  validate :verse_in_chapter

  def self.parse(bible_ref)
    bible_ref.strip!
    return nil if bible_ref.blank?
    bible_ref.downcase!

    # split the reference allowing a single digit book number
    # and a variety of chapter-verse delimiters
    ref_tokens = bible_ref.scan(/[1-3]?\s?[a-z]+|\d{1,3}\s*?[:|;|,|\.|\s]\s*?\d{1,3}/)
    return nil unless ref_tokens.length == 2
    chapter, verse = ref_tokens[1].split(%r{:|;|,|\.}).map(&:strip).map(&:to_i)
    # if the delimiter between chapter and verse is just whitespace then we have nothing in verse now
    chapter, verse = ref_tokens[1].split.map(&:strip).map(&:to_i) unless verse
    return nil unless chapter &.> 0 and verse &.> 0

    # find the book
    bookname = ref_tokens[0]
    bookname = bookname[0] + ' ' + bookname[1..-1].strip if bookname.starts_with?('1', '2', '3')
    bookname = bookname.titleize
    book = Book.find_by_name bookname
    book ||= Book.find_by_abbreviation bookname

    if book
      chapter = Chapter.find_by(book: book, number: chapter)
    else
      # we didn't recognise the book so make a guess
      chapters = Chapter.where(number: chapter).where('verses >= ?', verse)
      return nil if chapters.empty?
      # if there's only one book that fits the chapter-verse ref then use it
      if chapters.count == 1
        chapter = chapters.first
      else
        # try to narrow it down by progressively shortening the string of the book name
        abbr = chapters.joins(:book).pluck :id, :abbreviation
        len = 6
        chapter = nil
        until len < 0 or chapter
          nice_try = abbr.select{ |a| a[1][0..len] == bookname[0..len] }
          chapter = Chapter.find nice_try.first[0] if nice_try.length == 1
          len -= 1
        end
        return nil unless chapter
      end
    end
    BiblePassage.new(chapter: chapter, verse: verse)

  end

  def bible_ref(abbr = false)
    book = abbr ? chapter.book.abbreviation : chapter.book.name
    "#{book} #{chapter.number}:#{verse}"
  end

  private

  def verse_in_chapter
    errors.add(:verse, "too big. The chapter has only #{chapter.verses} verses") unless verse <= chapter.verses
  end

end
