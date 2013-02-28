class Fuse::Document::AssetCollection < Array

  def of_type(type)
    self.class.new select { |a| a.is_a? type }
  end

  def sort!
    unsorted = Array.new(self)
    clear
    unsorted.each { |a| push_with_dependents a }
    self
  end

  def sort
    self.class.new(self).sort!
  end

  def <<(*args)
    args.each { |arg| super(arg) unless include? arg }
    self
  end

  def push_with_dependents(asset)
    #todo check for circular references
    asset.dependents.each { |d| push_with_dependents d }
    self << asset
  end

end
