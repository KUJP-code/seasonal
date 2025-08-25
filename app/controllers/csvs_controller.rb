# frozen_string_literal: true

class CsvsController < ApplicationController
  ALLOWED_MODELS = %w[Child Invoice PaperTrail::Version
                      RegularSchedule Setsumeikai TimeSlot
                      User].freeze

  def index
    authorize(:csv)
    @events = Event.group(:name).pluck(:name)
  end

  def download
    authorize(:csv)
    model = params[:model].constantize if ALLOWED_MODELS.include?(params[:model])
    model_name = params[:model].downcase.pluralize if ALLOWED_MODELS.include?(params[:model])
    path = "/tmp/#{model_name}#{Time.zone.now.strftime('%Y%m%d%H%M')}.csv"

    File.open(path, 'wb') do |f|
      if params[:event]
        event_ids = Event.where(name: params[:event]).ids

        model.where(event_id: event_ids).copy_to do |line|
          f.write line
        end
      elsif model == PaperTrail::Version
        model.where(created_at: params[:from]..).copy_to do |line|
          f.write line
        end
      else
        model.copy_to do |line|
          f.write line
        end
      end
    end

    send_file path, type: 'text/csv', disposition: 'attachment'
  end

  def download_activities_by_event
    authorize(:csv)

    event_name = params[:event].to_s
    time       = Time.zone.now.strftime('%Y%m%d%H%M')
    safe_name  = event_name.parameterize.presence || "event"
    path       = "/tmp/activities_#{safe_name}_#{time}.csv"

    # All TimeSlots for all Events with this name (across schools)
    slots = TimeSlot
              .joins(event: :school)
              .where(events: { name: event_name })
              .includes(event: :school)
              .order(Arel.sql('schools.name ASC, COALESCE(time_slots.starts_at, time_slots.start_time) ASC, time_slots.id ASC'))

    CSV.open(path, 'wb') do |csv|
      csv << %w[school activity_name start_time end_time]

      # handle either starts_at/ends_at or start_time/end_time
      slots.find_each(batch_size: 500) do |slot|
        start_time = if slot.respond_to?(:starts_at) then slot.starts_at else slot.try(:start_time) end
        end_time   = if slot.respond_to?(:ends_at)   then slot.ends_at   else slot.try(:end_time)   end

        csv << [
          slot.event.school.name,
          slot.name,
          (start_time&.in_time_zone&.to_s || ''),
          (end_time&.in_time_zone&.to_s   || '')
        ]
      end
    end

    send_file path, type: 'text/csv', disposition: 'attachment'
  end

  
  def download_signups
    authorize(:csv)

    events   = Event.where(name: params[:event])
    invoices = Invoice
                 .real
                 .where(event_id: events.select(:id))
                 .includes(child: :school)


    filename = "#{params[:event]}_signups_#{Time.zone.now.strftime('%Y%m%d')}.csv"
    response.headers['Content-Type']        = 'text/csv; charset=utf-8'
    response.headers['Content-Disposition'] = %(attachment; filename="#{filename}")

    self.response_body = Enumerator.new do |y|
      y << CSV.generate_line([
        'SSID',
        'Name',
        'Name (Katakana)',
        'School',
        'Time-Slots Attended',
        'Total Cost (Net ¥)',
        'Photo Service Cost (¥)',
        'Category Value',
        'Confirm Date'
      ])

      invoices.find_each(batch_size: 500) do |inv|
        child              = inv.child
        timeslots_attended = inv.slot_regs.count
        photo_cost         = inv.options.event.sum(:cost)
        net_cost           = inv.total_cost - photo_cost
        confirm_date       = child.external? ? inv.updated_at.to_date.to_s : ''
        category_value     = case child.category
                             when 'internal', 'reservation' then 3
                             when 'external'                 then 2
                             else 'unknown'
                             end

        y << CSV.generate_line([
          child.ssid,
          child.name,
          child.katakana_name,
          child.school.name,
          timeslots_attended,
          net_cost,
          photo_cost,
          category_value,
          confirm_date
        ])
      end
    end
  ensure
    response.stream.close if response.stream.respond_to?(:close)
  end

  def photo_kids
    authorize(:csv)
    path = "/tmp/photo_kids#{Time.zone.now.strftime('%Y%m%d%H%M')}.csv"
    photo_kids = Child.where(
      parent_id: Child.where(
        id: Registration.where(
          registerable_id: Option.where(
            optionable_id: Event.where(name: params[:event]).select(:id), optionable_type: 'Event'
          ).select(:id), registerable_type: 'Option'
        ).select(:child_id)
      ).select(:parent_id)
    ).includes(:school)
    headers = %w[name katakana_name en_name category school SSID]
    is_party = Event.find_by(name: params[:event]).party?
    if is_party
      photo_kids = kids_with_timeslot(photo_kids,
                                      params[:event])
      headers << 'party_name'
    end

    CSV.open(path, 'wb') do |csv|
      csv << headers
      photo_kids.each do |kid|
        values = [kid.name, kid.katakana_name, kid.en_name, kid.category, kid.school.name,
                  kid.ssid]
        values << kid.time_slots.map(&:name).join(' & ') if is_party
        csv << values
      end
    end
    send_file path, type: 'text/csv', disposition: 'attachment'
  end

  def emails
    authorize(:csv)
    event_ids = Event.where(name: params[:event]).ids
    emails = Child.includes(:invoices, :parent)
                  .where(invoices: { event_id: event_ids })
                  .pluck('users.email')
    time = Time.zone.now.strftime('%Y%m%d%H%M')
    path = "/tmp/#{params[:event].downcase.tr(' ', '_')}emails#{time}.csv"

    generate_email_csv(path, emails)

    send_file path, type: 'text/csv', disposition: 'attachment'
  end

  def no_photo_emails
    authorize(:csv)
    event_ids = Event.where(name: params[:event]).ids
    photo_opt_ids = Option.where(category: :event, optionable_id: event_ids).ids
    invoices = Invoice.where(event_id: event_ids)
                      .includes(:options, child: :parent)
                      .reject { |i| i.options.any? { |opt| photo_opt_ids.include?(opt.id) } }
    # TODO: name/format this properly
    emails = invoices.map { |i| [i.child.parent.email, i.child.school_id, i.event_id] }.uniq
    time = Time.zone.now.strftime('%Y%m%d%H%M')
    path = "/tmp/#{params[:event].downcase.tr(' ', '_')}emails#{time}.csv"

    generate_email_csv(path, emails)

    send_file path, type: 'text/csv', disposition: 'attachment'
  end

  def update
    authorize(:csv)
    csv = params[:csv]
  
    begin
      if params[:model] == 'Child'
        update_child(csv)
      elsif params[:model] == 'Setsumeikai'
        update_setsumeikai(csv)
      else
        update_schedule(csv)
      end
  
      flash[:notice] = "#{params[:model]} records updated."
    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = "Failed to update #{params[:model]} records: #{e.message}"
    rescue StandardError => e
      flash[:alert] = "An unexpected error occurred: #{e.message}"
    ensure
      redirect_to csvs_path
    end
  end
  

  def upload
    authorize(:csv)
    csv = params[:csv]
    model = params[:model].constantize if ALLOWED_MODELS.include?(params[:model])
    time = Time.zone.now

    model.copy_from(csv.tempfile.path) do |row|
      # Data from the SS doesn't come with created_at/updated_at, so we
      # need to set them ourselves
      row[12] = time
      row[13] = time
    end

    redirect_to csvs_path,
                notice: "#{if ALLOWED_MODELS.include?(params[:model])
                             params[:model]
                           end} records imported."
  end

  private

  def kids_with_timeslot(relation, event_name)
    relation.includes(:time_slots).where(time_slots: { event_id: Event.where(name: event_name).select(:id) })
  end

  # Some SS data is missing required fields, so we need to set default values
  def defaults(row)
    row['name'] = 'なし' if row['name'].nil?
    row['katakana_name'] = 'ナシ' if row['katakana_name'].nil?
    row['en_name'] = 'なし' if row['en_name'].nil?
    row['birthday'] = 'なし' if row['birthday'].nil?
    row['allergies'] = 'Unknown' if row['allergies'].nil?
    row['photos'] = 'NG' if row['photos'].nil?
  end

  def generate_email_csv(path, emails)
    CSV.open(path, 'wb') do |csv|
      csv << ['email']
      emails.each do |email|
        csv << [email]
      end
    end
  end

  # Find the child from provided SSID and set their child_id/
  # remove ssid from the hash
  def get_child_id(row)
    child_id = Child.find_by(ssid: row['ssid']).id
    row['child_id'] = child_id
    row.delete('ssid')
    child_id
  end

  # The CSV method doesn't accept int values for enums, so we need to
  # translate to the string values
  def translate_enums(row)
    row['category'] = Child.categories.key(row['category'].to_i)
    row['grade'] = Child.grades.key(row['grade'].to_i)
    row['photos'] = Child.photos.key(row['photos'].to_i)
  end

  # Update Child records if present, otherwise create new ones
  def update_child(csv)
    CSV.foreach(csv.tempfile.path, headers: true) do |row|
      translate_enums(row)
      defaults(row)

      if Child.find_by(ssid: row['ssid'])
        Child.find_by(ssid: row['ssid']).update!(row.to_hash)
      else
        Child.create!(row.to_hash)
      end
    end
  end

  def update_setsumeikai(csv)
    CSV.foreach(csv.tempfile.path, headers: true) do |row|
      hash = row.to_h

      Setsumeikai.create!(
        hash.merge(
          setsumeikai_involvements_attributes: [{ school_id: hash['school_id'] }]
        )
      )
    end
  end

  # Update Schedule records if present, otherwise create new ones
  def update_schedule(csv)
    CSV.foreach(csv.tempfile.path, headers: true) do |row|
      child_id = get_child_id(row)

      if Child.find(child_id)&.regular_schedule.nil?
        Child.find(child_id).create_regular_schedule(row.to_hash)
      else
        RegularSchedule.find_by(child_id:).update!(row.to_hash)
      end
    end
  end
end
