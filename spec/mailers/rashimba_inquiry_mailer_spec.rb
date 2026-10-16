# frozen_string_literal: true

require 'rails_helper'
require 'digest'

RSpec.describe RashimbaInquiryMailer do
  shared_examples 'a branded confirmation' do
    it 'includes HTML and plain text with all of the original copy' do
      expect(mail.text_part.mime_type).to eq('text/plain')
      expect(mail.html_part.mime_type).to eq('text/html')
      html = Nokogiri::HTML(mail.html_part.body.decoded)
      visible_copy = html.at('body').text.gsub(/[[:space:]―]/, '')
      mail.text_part.body.decoded.split(/\r?\n\s*\r?\n/).each do |paragraph|
        original_copy = paragraph.gsub(/[[:space:]―]/, '')
        expect(visible_copy).to include(original_copy)
      end
      expect(html.at('html')['lang']).to eq('ja')
      expect(html.css('script, iframe, form')).to be_empty
      expect(html.css('h1').text).to eq(mail.subject.delete_prefix('【らしんば】'))
    end

    it 'embeds the small brand logo without remote image requests' do
      parsed = Mail.read_from_string(mail.encoded)
      logo = parsed.attachments.find { |attachment| attachment.filename == 'rashimba-logo.png' }
      expect(logo).to be_inline
      expect(logo.mime_type).to eq('image/png')
      expect(logo.body.decoded.bytesize).to be < 30_000
      html = Nokogiri::HTML(parsed.html_part.body.decoded)
      expect(html.css('img').size).to eq(1)
      expect(html.at('img')['src']).to eq("cid:#{logo.cid}")
      expect(html.at('img')['alt']).to eq('らしんば')
      expect(parsed.encoded.bytesize).to be < 4_000_000
    end
  end

  context 'with a sponsor inquiry' do
    subject(:mail) { described_class.with(inquiry:).confirmation }

    let(:inquiry) { create(:rashimba_inquiry, company: '株式会社Example', name: '山田 太郎') }

    include_examples 'a branded confirmation'

    it 'uses the supplied subject, greeting, sponsor copy, and contact address' do
      expect(mail.subject).to eq('【らしんば】資料請求ありがとうございます（資料を送付いたします）')
      expect(mail.from).to eq(['notifications@rashimba.com'])
      expect(mail.to).to eq([inquiry.email])
      expect(mail.reply_to).to eq(['info@rashimba.com'])
      expect(mail.text_part.body.decoded)
        .to start_with("#{inquiry.company}\r\n#{inquiry.name}様\r\n")
      expect(mail.text_part.body.decoded).to include(
        'サービス案内資料を本メールに添付', '■ らしんばとは', '■ 資料の内容', '■ 次のステップ',
        'オンラインでのご説明（30分程度）', 'Mail：info@rashimba.com',
        '東京都千代田区六番町10-2 六番町市川ビル1階', 'TEL：03-6272-4053'
      )
    end

    it 'attaches the email-sized PDF with its Japanese filename and correct MIME type' do
      attachments = mail.attachments.reject(&:inline?)
      expect(attachments.size).to eq(1)
      attachment = attachments.first
      expect(attachment.filename).to eq('らしんば_サービス案内資料.pdf')
      expect(attachment.mime_type).to eq('application/pdf')
      expect(attachment.body.decoded).to start_with('%PDF-')
      expect(attachment.body.decoded.bytesize).to be < 3_000_000
      expect(Digest::SHA256.hexdigest(attachment.body.decoded))
        .to eq('33890ac8f62caf3fa3309d0547d1296dbbaa53b8ae40a1970b3fc97c70e6e849')
    end

    it 'preserves the filename and PDF bytes through MIME serialization' do
      parsed = Mail.read_from_string(mail.encoded)
      attachment = parsed.attachments.find { |part| part.mime_type == 'application/pdf' }
      expect(attachment.filename).to eq('らしんば_サービス案内資料.pdf')
      expect(attachment.body.decoded).to eq(File.binread(described_class::SPONSOR_GUIDE_PATH))
    end

    it 'does not send a confirmation if the promised attachment is unavailable' do
      allow(File).to receive(:binread).and_call_original
      allow(File).to receive(:binread).with(described_class::SPONSOR_GUIDE_PATH)
                                      .and_raise(Errno::ENOENT)
      deliveries = ActionMailer::Base.deliveries.size
      expect { mail.deliver_now }.to raise_error(Errno::ENOENT)
      expect(ActionMailer::Base.deliveries.size).to eq(deliveries)
    end

    it 'escapes submitted names and companies in the HTML without changing their text' do
      inquiry.update!(company: '<script>alert("company")</script>',
                      name: '<img src=x onerror=alert(1)>')
      html = Nokogiri::HTML(mail.html_part.body.decoded)
      expect(html.css('script')).to be_empty
      expect(html.css('img').size).to eq(1)
      expect(html.at('body').text).to include(inquiry.company, "#{inquiry.name}様")
      expect(mail.text_part.body.decoded).to include(inquiry.company, inquiry.name)
    end

    it 'does not turn a submitted company URL into an active link' do
      inquiry.update!(company: 'https://example.net/untrusted')
      html = Nokogiri::HTML(mail.html_part.body.decoded)
      expect(html.at('body').text).to include(inquiry.company)
      expect(html.css('a').pluck('href')).not_to include(inquiry.company)
    end
  end

  context 'with a parent release notification' do
    subject(:mail) { described_class.with(inquiry:).confirmation }

    let(:inquiry) { create(:rashimba_inquiry, :release_notification) }

    include_examples 'a branded confirmation'

    it 'uses the supplied parent subject, release copy, social links, and support address' do
      expect(mail.subject).to eq('【らしんば】お知らせ登録ありがとうございます。')
      expect(mail.from).to eq(['notifications@rashimba.com'])
      expect(mail.to).to eq([inquiry.email])
      expect(mail.reply_to).to eq(['support@rashimba.com'])
      expect(mail.text_part.body.decoded).to include(
        'お知らせ登録を', '2026年12月予定', 'https://www.instagram.com/rashimba_app',
        'https://x.com/rashimba_app', 'https://camp-fire.jp/projects/963630',
        'Mail：support@rashimba.com', '東京都千代田区六番町10-2 六番町市川ビル1階',
        'TEL：03-6272-4053'
      )
      expect(mail.text_part.body.decoded).not_to include('本メールに添付')
    end

    it 'does not attach or read the sponsor brochure' do
      allow(File).to receive(:binread).and_call_original
      expect(mail.attachments.reject(&:inline?)).to be_empty
      expect(File).not_to have_received(:binread).with(described_class::SPONSOR_GUIDE_PATH)
    end
  end

  it 'keeps internal notifications addressed to the staff mailbox without attachments' do
    inquiry = create(:rashimba_inquiry)
    mail = described_class.with(inquiry:).notification
    expect(mail.to).to eq(['j-kusaka@kids-up.jp'])
    expect(mail.reply_to).to eq([inquiry.email])
    expect(mail.attachments).to be_empty
    expect(mail.body.decoded).to include(inquiry.company, inquiry.name, inquiry.email)
  end
end
