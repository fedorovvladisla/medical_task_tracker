class Tag < ApplicationRecord
  has_many :task_tags, dependent: :destroy
  has_many :tasks, through: :task_tags
  validates :name, presence: true, uniqueness: true
  SYSTEM_TAGS = %w[отчетность операции звонок].freeze
  def system?
    system || SYSTEM_TAGS.include?(name)
  end
  before_destroy :prevent_system_deletion
  before_update :prevent_system_name_change, if: :will_save_change_to_name?

  private

  def prevent_system_deletion
    if system?
      errors.add(:base, "нельзя удалить тег '#{name}'")
      throw(:abort)
    end
  end

  def prevent_system_name_change
    if system?
      errors.add(:name, "нельзя изменить имя тега")
      throw(:abort)
    end
  end
end