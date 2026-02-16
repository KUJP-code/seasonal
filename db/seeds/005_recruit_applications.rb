# frozen_string_literal: true

require 'securerandom'

rng = Random.new(20_260_216)
roles = RecruitApplication::ROLES
sources = %w[tiktok facebook instagram line google yahoo]
mediums = %w[paid_social cpc organic referral]
campaigns = %w[spring_hiring summer_hiring tokyo_native driver_push new_grad_2026]
tracking_slugs = %w[
  tk-sm-01
  fb-bilingual-01
  ig-native-01
  ln-driver-01
  gg-tour-01
  yh-newgrad-01
]
nationalities = ['Japan', 'USA', 'Canada', 'UK', 'Australia', 'Philippines']
genders = ['male', 'female', 'non_binary', nil]
education_levels = [
  'High School',
  'Vocational School',
  'Associate Degree',
  'Bachelor\'s Degree',
  'Master\'s Degree'
]
visa_statuses = ['yes', 'no', 'in_process']

tracking_slugs.each do |slug|
  RecruitTrackingLink.find_or_create_by!(slug:) do |link|
    link.name = slug
    link.active = true
  end
end

seeded = 0

(1..30).each do |n|
  role = roles[(n - 1) % roles.length]
  email = format('recruit.seed.%02d@example.com', n)
  source = sources[rng.rand(sources.length)]
  medium = mediums[rng.rand(mediums.length)]
  campaign = campaigns[rng.rand(campaigns.length)]
  submitted_at = n.days.ago.change(hour: rng.rand(9..20), min: rng.rand(0..59), sec: 0)

  attrs = {
    role: role,
    email: email,
    phone: format('090-%04d-%04d', rng.rand(1000..9999), rng.rand(1000..9999)),
    full_name: Faker::Name.name,
    date_of_birth: Date.new(rng.rand(1980..2004), rng.rand(1..12), rng.rand(1..28)),
    full_address: Faker::Address.full_address,
    gender: genders[rng.rand(genders.length)],
    highest_education: education_levels[rng.rand(education_levels.length)],
    employment_history: "#{rng.rand(1..8)} years in education/customer support.",
    reason_for_application: (role == 'native' ? 'Interested in child-focused English education.' : nil),
    nationality: nationalities[rng.rand(nationalities.length)],
    work_visa_status: (role == 'native' ? visa_statuses[rng.rand(visa_statuses.length)] : nil),
    questions: (rng.rand < 0.35 ? 'Can you share expected onboarding timing?' : nil),
    privacy_policy_consent: true,
    utm_source: source,
    utm_medium: medium,
    utm_campaign: campaign,
    utm_term: (rng.rand < 0.45 ? "term_#{rng.rand(1..20)}" : nil),
    utm_content: "creative_#{rng.rand(1..12)}",
    gclid: (source == 'google' ? "gclid_#{SecureRandom.hex(6)}" : nil),
    fbclid: (%w[facebook instagram].include?(source) ? "fbclid_#{SecureRandom.hex(6)}" : nil),
    ttclid: (source == 'tiktok' ? "ttclid_#{SecureRandom.hex(6)}" : nil),
    tracking_link_slug: tracking_slugs[rng.rand(tracking_slugs.length)],
    tracking_click_id: "click_#{SecureRandom.hex(5)}",
    attribution_method: %w[param cookie mixed][rng.rand(3)],
    landing_page_url: 'https://kids-up.jp/lp-recruit',
    referrer_url: "https://kids-up.jp/r/#{tracking_slugs[rng.rand(tracking_slugs.length)]}",
    raw_tracking: {
      last_click_at: submitted_at.iso8601,
      channel: source,
      campaign: campaign
    },
    ip_address: "203.0.113.#{rng.rand(1..254)}",
    user_agent: 'Mozilla/5.0 (RecruitSeedBot)',
    locale: %w[ja en][rng.rand(2)],
    created_at: submitted_at,
    updated_at: submitted_at
  }

  application = RecruitApplication.find_or_initialize_by(email: email)
  application.assign_attributes(attrs)
  application.save!
  seeded += 1
end

puts "Upserted #{seeded} recruit applications"
