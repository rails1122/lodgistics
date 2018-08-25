class InitialsImageService
  FONT_RATIO = 0.45
  RESIZE_FILTER = Magick::LagrangeFilter
  RESIZE_BLUR = 1
  DEFAULT_OUTPUT_SIZE = 200
  Y_OFFSET = 0                 #0.04
  BACKGROUND_COLOR = "#00ADDD" #"#DBDBDB"
  FILL = "#FFFFFF"             #"#000000"

  def create_image(initials)
    output_size = DEFAULT_OUTPUT_SIZE
    canvas_size = DEFAULT_OUTPUT_SIZE

    img = Magick::Image.new(canvas_size, canvas_size) do
      self.format = "png"
      self.background_color = BACKGROUND_COLOR
    end

    txt = initials[0..1].upcase
    pointsize = get_pointsize(canvas_size * FONT_RATIO, txt)

    Magick::Draw.new.annotate(img, canvas_size, canvas_size, 0, canvas_size*Y_OFFSET, txt) do
      self.fill = FILL
      self.gravity = Magick::CenterGravity
      self.pointsize = pointsize
      self.font_weight = Magick::BoldWeight
    end

    img.resize(output_size,output_size, RESIZE_FILTER, RESIZE_BLUR)
  end

  private

  def get_pointsize(default_size, txt)
    return default_size * 0.6 if txt.length == 3
    return default_size * 1.1 if txt.length == 1
    default_size
  end
end
