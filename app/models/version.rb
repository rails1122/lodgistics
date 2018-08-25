#
# Taken from: https://stackoverflow.com/questions/2051229/how-to-compare-versions-in-ruby
#
class Version < Array
  def initialize s
    super(s.to_s.split('.').map { |e| e.to_i })
  end
  def < x
    (self <=> x) < 0
  end
  def > x
    (self <=> x) > 0
  end
  def == x
    (self <=> x) == 0
  end
end
