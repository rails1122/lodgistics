require "google/cloud/translate"

unless Rails.env.test?
  gcloud = Google::Cloud.new
  GoogleTranslate = gcloud.translate ENV['TRANSLATE_KEY'] || Settings.google_translate_key

  # Force loading module
  Translation.class
end
