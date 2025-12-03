module JournalsHelper
  def render_transcript_with_comments(journal)
    text     = journal.transcript || ""
    comments = journal.comments.order(:start_index)

    result  = +""
    cursor  = 0

    comments.each do |comment|
      next if comment.start_index >= comment.end_index
      next if comment.start_index >= text.length

      start   = comment.start_index
      end_idx = [comment.end_index, text.length].min

      result << ERB::Util.html_escape(text[cursor...start])

      segment = ERB::Util.html_escape(text[start...end_idx])
      result << %(<span class="journal-highlight" data-comment-id="#{comment.id}">#{segment}</span>)

      cursor = end_idx

    end

    result << ERB::Util.html_escape(text[cursor..])

    result.html_safe
  end
end
