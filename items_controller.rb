require './controller'

class ItemsController < Controller
  def want_to_process?(request)
    request.path.start_with?('/items')
  end

  def process_request(request)
    '<html><body>hello from items controller</body></html>'
  end
end
