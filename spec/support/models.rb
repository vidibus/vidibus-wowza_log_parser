class Model
  include Mongoid::Document
  include Vidibus::WowzaLogParser::Mongoid
end
