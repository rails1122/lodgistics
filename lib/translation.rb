class Translation
  include Singleton

  # It will guess the +text+ language, and translate if:
  # - +text+ is English => translate to Spanish
  # - +text+ is other   => translate to English
  #
  def self.auto_translate(text)
    result = GoogleTranslate.detect text
    
    to_language = case result.language
    when "en"
      "es"
    else
      "en"
    end

    result = GoogleTranslate.translate text, to: to_language
    result.text
  end

end
