module VersionCheckerHelper
  def is_version_or_higher(target_version, current_version)
    Gem::Version.new(current_version) >= Gem::Version.new(target_version)
  end
end