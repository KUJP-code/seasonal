# frozen_string_literal: true

require 'rails_helper'
require 'digest'

RSpec.describe RashimbaInquiryMailer do
  context 'with a sponsor inquiry' do
    subject(:mail) { described_class.with(inquiry:).confirmation }

    let(:inquiry) { create(:rashimba_inquiry, company: '株式会社Example', name: '山田 太郎') }

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

    it 'attaches the original PDF with its Japanese filename and correct MIME type' do
      expect(mail.attachments.size).to eq(1)
      attachment = mail.attachments.first
      expect(attachment.filename).to eq('らしんば_サービス案内資料.pdf')
      expect(attachment.mime_type).to eq('application/pdf')
      expect(attachment.body.decoded).to start_with('%PDF-')
      expect(attachment.body.decoded.bytesize).to eq(6_046_043)
      expect(Digest::SHA256.hexdigest(attachment.body.decoded))
        .to eq('bca431cd6241b07a834f3455af13976a9dff50b25d2c25e0c1da2150031da7c9')
    end

    it 'preserves the filename and PDF bytes through MIME serialization' do
      parsed = Mail.read_from_string(mail.encoded)
      attachment = parsed.attachments.first
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
  end

  context 'with a parent release notification' do
    subject(:mail) { described_class.with(inquiry:).confirmation }

    let(:inquiry) { create(:rashimba_inquiry, :release_notification) }

    it 'uses the supplied parent subject, release copy, social links, and support address' do
      expect(mail.subject).to eq('【らしんば】お知らせ登録ありがとうございます。')
      expect(mail.from).to eq(['notifications@rashimba.com'])
      expect(mail.to).to eq([inquiry.email])
      expect(mail.reply_to).to eq(['support@rashimba.com'])
      expect(mail.body.decoded).to include(
        'お知らせ登録を', '2026年12月予定', 'https://www.instagram.com/rashimba_app',
        'https://x.com/rashimba_app', 'https://camp-fire.jp/projects/963630',
        'Mail：support@rashimba.com', '東京都千代田区六番町10-2 六番町市川ビル1階',
        'TEL：03-6272-4053'
      )
      expect(mail.body.decoded).not_to include('本メールに添付')
    end

    it 'does not attach or read the sponsor brochure' do
      allow(File).to receive(:binread).and_call_original
      expect(mail.attachments).to be_empty
      expect(File).not_to have_received(:binread).with(described_class::SPONSOR_GUIDE_PATH)
    end
  end

  it 'keeps internal notifications addressed to the staff mailbox without attachments' do
    inquiry = create(:rashimba_inquiry)
    mail = described_class.with(inquiry:).notification
    expect(mail.to).to eq(['p-jayson@kids-up.jp'])
    expect(mail.reply_to).to eq([inquiry.email])
    expect(mail.attachments).to be_empty
    expect(mail.body.decoded).to include(inquiry.company, inquiry.name, inquiry.email)
  end
end
