# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: manga
#
#  id                        :integer          not null, primary key
#  abbreviated_titles        :string           is an Array
#  average_rating            :float
#  canonical_title           :string           default("en_jp"), not null
#  chapter_count             :integer
#  cover_image_content_type  :string(255)
#  cover_image_file_name     :string(255)
#  cover_image_file_size     :integer
#  cover_image_top_offset    :integer          default(0)
#  cover_image_updated_at    :datetime
#  end_date                  :date
#  poster_image_content_type :string(255)
#  poster_image_file_name    :string(255)
#  poster_image_file_size    :integer
#  poster_image_updated_at   :datetime
#  rating_frequencies        :hstore           default({}), not null
#  serialization             :string(255)
#  slug                      :string(255)
#  start_date                :date
#  status                    :integer
#  subtype                   :integer          default(1), not null
#  synopsis                  :text
#  titles                    :hstore           default({}), not null
#  user_count                :integer          default(0), not null
#  volume_count              :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# rubocop:enable Metrics/LineLength

class Manga < ApplicationRecord
  include Media

  enum subtype: %i[manga novel manhua oneshot doujin]
  enum status: %i[not_published publishing finished]
  alias_attribute :progress_limit, :chapter_count
  alias_attribute :manga_type, :subtype

  has_many :chapters

  validates :chapter_count, numericality: { greater_than: 0 }, allow_nil: true

  def unit(number)
    chapters.where(number: number).first
  end

  def default_progress_limit
    # TODO: Actually provide good logic for this
    5000
  end

  def slug_candidates
    [
      -> { canonical_title }, # attack-on-titan
      -> { titles[:en_jp] }, # shingeki-no-kyojin
      -> { [titles[:en_jp], year] }, # shingeki-no-kyojin-2004
      -> { [titles[:en_jp], year, subtype] } # shingeki-no-kyojin-2004-doujin
    ]
  end
end
