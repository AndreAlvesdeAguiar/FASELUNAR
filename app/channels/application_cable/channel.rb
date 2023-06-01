module ApplicationCable
  class Channel < ActionCable::Channel::Base
    def subscribed
      stream_from 'sensor_data'
    end
  end
end
