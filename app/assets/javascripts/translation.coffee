$ ->

  $(document).on 'dblclick', 'p.media-text, .message-detail .pl5', (e) ->
    text = $(@).html()
    $this = $(@)
    $content = $(@).parents(".message-body")
    originalText = $(@).data("original")
    translated = $this.data("translated")

    if translated
      $this.html(originalText)
      $this.data("translated", false)
    else
      translation = $this.data("translation")
      if translation
        $this.html(translation)
        $this.data("translated", true)
      else
        $content.append("""<div class="indicator show"><span class="spinner"></span></div>""")
        $.ajax(
          url: Routes.translation_path {format: "JSON"}
          type: "POST"
          dataType: "JSON"
          data: { text: text }
        ).done( (data) ->
          $this.data("original", text)
          $this.data("translation", data.text)
          $this.data("translated", true)
          $this.html(data.text)
        ).fail( ->
          alert 'Failed to get translation'
        ).always( ->
          $content.find(".indicator.show").remove()
        )
