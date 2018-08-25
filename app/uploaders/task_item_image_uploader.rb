# encoding: utf-8

class TaskItemImageUploader < CarrierWave::Uploader::Base

  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage Rails.env.test? ? :file : :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
