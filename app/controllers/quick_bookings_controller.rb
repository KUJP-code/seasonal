class QuickBookingsController < ApplicationController

  def new
    @quick_booking = QuickBooking.new
    @schools = School.order(:name)
  end

  def create
    @quick_booking = QuickBooking.new(quick_booking_params)
    if @quick_booking.save
      QuickBookingMailer.notify_manager(@quick_booking).deliver_later
      QuickBookingMailer.confirmation(@quick_booking).deliver_later
      redirect_to thank_you_quick_booking_path, notice: "Your booking has been received. Please check your email for further instructions."
    else
      @schools = School.order(:name)
      flash.now[:alert] = @quick_booking.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def thank_you; end

  def timeslots
    school = School.find(params[:school_id])
    party_event = school.events.where(released: true).order(start_date: :asc).find { |event| event.party? }
    timeslots = party_event ? party_event.time_slots.where(closed: false).order(:start_time) : []
    render json: {
      party_event: party_event ? {
        id: party_event.id,
        name: party_event.name,
        image_url: (party_event.avif.attached? ? url_for(party_event.avif) : (party_event.image.attached? ? url_for(party_event.image) : ""))
      } : nil,
      timeslots: timeslots.map do |t|
        t.as_json(only: [:id, :name, :start_time, :end_time]).merge(
          image_url: (t.image.attached? ? url_for(t.image) : "")
        )
      end
    }
  end

  private

  def quick_booking_params
    params.require(:quick_booking).permit(:first_name, :last_name, :email, :phone, :school_id, :timeslot_id, :event_id)
  end
end
