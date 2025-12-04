module JournalsHelper
  def render_transcript_with_comments(string, journal, transcript_index)
    # text     = journal.transcript.gsub(/```json\n|```/, '') || ""
    comments = journal.comments.where(transcript_index: transcript_index).order(:start_index)

    result  = +""
    cursor  = 0

    comments.each do |comment|
      next if comment.start_index >= comment.end_index
      next if comment.start_index >= string.length

      start   = comment.start_index
      end_idx = [comment.end_index, string.length].min

      result << ERB::Util.html_escape(string[cursor...start])

      segment = ERB::Util.html_escape(string[start...end_idx])
      result << %(<span class="journal-highlight" data-comment-id="#{comment.id}">#{segment}</span>)

      cursor = end_idx

    end

    result << ERB::Util.html_escape(string[cursor..])

    result.html_safe
  end
end
