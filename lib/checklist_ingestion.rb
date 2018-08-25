# Handles ingestion of checklists from spreadsheets
module ChecklistIngestion
  class SpreadsheetError < StandardError; end

  MIMETYPE_HANDLERS = {
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => Roo::Excelx
  }

  FIRST_ROW = 2

  COLUMNS = {
      category_title:     'A',
      item_title:         'B'
  }

  # Returns a roo spreadsheet object to handle the given file
  def self.spreadsheet_for(file)
    mime_types = MIME::Types.type_for(file.original_filename).map(&:content_type)
    handlers = mime_types.map{|mt| MIMETYPE_HANDLERS[mt]}.compact

    raise SpreadsheetError if handlers.empty?

    spreadsheet = handlers.first.new(file.path)

    spreadsheet.default_sheet = spreadsheet.sheets.first

    return spreadsheet
  end

  def self.read_excel(task_list, file)
    begin
      ss = spreadsheet_for(file)
    rescue SpreadsheetError => e
      return false
    end

    items = []

    FIRST_ROW.upto ss.last_row do |row|
      category = task_list.task_items.find_or_initialize_by title: ss.cell(row, COLUMNS[:category_title])
      category.row_order = row
      category.save!

      item = category.items.find_or_initialize_by title: ss.cell(row, COLUMNS[:item_title])
      item.task_list_id = category.task_list_id
      item.row_order = row
      item.save!
    end
    items
  end
end
