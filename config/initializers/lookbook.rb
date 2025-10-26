if Rails.env.development?
  Lookbook.configure do |config|
    config.preview_paths = [ "spec/components/previews" ]
    # config.preview_layout = "lookbook"
    config.auto_refresh
  end
end
