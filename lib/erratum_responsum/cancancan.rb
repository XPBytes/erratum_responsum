require 'cancan/exceptions'

module ErratumResponsum
  class NothingAccessibleBy < CanCan::AccessDenied
    def initialize(model)
      # noinspection RubyArgCount
      super format('You\'re not allowed to access that %<model>s', model: model), nil, model
    end
  end
end
