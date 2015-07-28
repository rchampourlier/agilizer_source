# object @issues
#
# extends 'issues/item'
#
# collection @issues, root: :issues, object_root: false

object false

# child @issues => :issues do
#   extends 'issues/item'
# end

node :issues do
  @issues.map do |issue|
    partial 'issues/item', object: issue, root: false
  end
end

node(:statistics) { @statistics }
node(:filter) do
  {
    available: @available_filter,
    applied: @applied_filter
  }
end
