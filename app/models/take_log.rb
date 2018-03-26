class TakeLog < ApplicationRecord
 validates :take_count, numericality: { less_than: 7 }

  belongs_to :card, counter_cache: true

  def self.today
    where("created_at >= ?", Time.zone.now.beginning_of_day)
  end
end
