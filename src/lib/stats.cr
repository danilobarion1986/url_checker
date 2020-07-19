class Stats
  # Creates a type from another type, given it a more representative name
  alias UrlInfo = NamedTuple(success: Int32, failure: Int32)

  # Defines what each Enumerable method will yield when used with a block
  include Enumerable({String, UrlInfo})

  delegate each, to: @hash

  def initialize
    # Hash key is a String and the values are named tuples -> {name: Type, other_name: OtherType}
    # Default value passed to Hash#new
    @hash = Hash(String, {success: Int32, failure: Int32}).new({success: 0, failure: 0})
  end

  def log_success(url : String)
    current = @hash[url][:success]
    @hash[url] = @hash[url].merge({success: current + 1})
  end

  def log_failure(url : String)
    current = @hash[url][:failure]
    @hash[url] = @hash[url].merge({failure: current + 1})
  end
end
