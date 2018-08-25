class MobileVersion < ApplicationRecord
  enum platform: [ :ios, :android ]

  validates :platform, presence: true
  validates :version, presence: true, uniqueness: { scope: :platform }

  attr_accessor :message, :prompt_for_upgrade

  def self.check_for_update(platform, current_version)
    ultimate = MobileVersion.last_version(platform)
    if ultimate.nil?
      MobileVersion.new(message: "There are no mobile apps", prompt_for_upgrade: false)
    else
      mv = self.where(platform: platform, version: current_version).first
      if Version.new(ultimate.version) > Version.new(mv&.version || 0)
        MobileVersion.new(
          message: "There is a new version available",
          prompt_for_upgrade: true,
          update_mandatory: ultimate.update_mandatory || false)
      else        
        MobileVersion.new(
          message: "You have installed latest version",
          prompt_for_upgrade: false)
      end
    end
  end

  def self.last_version(platform)
    self.where(platform: platform).to_a.sort_by{ |v| Version.new(v.version) }.last
  end

end
