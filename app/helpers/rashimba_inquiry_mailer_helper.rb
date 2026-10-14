# frozen_string_literal: true

module RashimbaInquiryMailerHelper
  # Only link published URLs and contact details. Escape all other copy,
  # including names and company names supplied through the public forms.
  LINK_PATTERN = %r{(https://[a-zA-Z0-9./_\#?=&%+\-]+|(?:info|support)@rashimba\.com|03-6272-4053)}
  LINK_DESTINATIONS = {
    'https://rashimba.com' => 'https://rashimba.com',
    'https://www.instagram.com/rashimba_app' => 'https://www.instagram.com/rashimba_app',
    'https://x.com/rashimba_app' => 'https://x.com/rashimba_app',
    'https://camp-fire.jp/projects/963630' => 'https://camp-fire.jp/projects/963630',
    'info@rashimba.com' => 'mailto:info@rashimba.com',
    'support@rashimba.com' => 'mailto:support@rashimba.com',
    '03-6272-4053' => 'tel:+81362724053'
  }.freeze

  def rashimba_email_copy(copy, breaks: false)
    lines = copy.lines.map { |line| rashimba_email_linked_line(line.strip) }
    safe_join(lines, breaks ? tag.br : '')
  end

  private

  def rashimba_email_linked_line(line)
    safe_join(line.split(LINK_PATTERN).map do |part|
      destination = LINK_DESTINATIONS[part]
      destination ? rashimba_email_link(part, destination) : ERB::Util.html_escape(part)
    end)
  end

  def rashimba_email_link(label, url)
    link_to label, url,
            style: 'color: #117c4d; text-decoration: underline; overflow-wrap: anywhere; ' \
                   'word-break: break-all;'
  end
end
