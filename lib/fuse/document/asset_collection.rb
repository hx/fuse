class Fuse::Document::AssetCollection < Array

  def of_type(*types)
    self.class.new select { |a|
      ret = types.include? a.class
      types.each { |type| ret ||= a.is_a? type } unless ret
      ret
    }
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

  def group_by(*args, &block)
    Hash[super(*args, &block).map{ |k, v| [k, self.class.new(v)] }]
  end

end
