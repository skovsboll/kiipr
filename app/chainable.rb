module Chainable
  def >>(other)
    self.addTarget other
    other
  end
end

class GPUImageFilter
  include Chainable
end

class GPUImageVideoCamera
  include Chainable
end

class GPUImageFilterGroup
  include Chainable
end

class GPUImageOutput
  include Chainable
end