class FlightsController < ApplicationController
  def index
    @flights = nil
  end

  def search
    origin = params[:origin].to_s.strip
    destination = params[:destination].to_s.strip
    start_date = parse_date_param(params[:start_date])
    end_date = parse_date_param(params[:end_date])

    if origin.blank? || destination.blank?
      flash.now[:alert] = "Source and destination airport codes are required."
      @flights = nil
      return render :index, status: :unprocessable_entity
    end

    if origin.length != 3 || destination.length != 3
      flash.now[:alert] = "Airport codes must be exactly 3 characters."
      @flights = nil
      return render :index, status: :unprocessable_entity
    end

    if start_date.nil? || end_date.nil?
      flash.now[:alert] = "Please select a valid start and end date."
      @flights = nil
      return render :index, status: :unprocessable_entity
    end

    if start_date > end_date
      flash.now[:alert] = "Start date must be on or before end date."
      @flights = nil
      return render :index, status: :unprocessable_entity
    end

    @flights = Flight.search(
      origin: origin,
      destination: destination,
      start_date: start_date,
      end_date: end_date
    )
    @search_params = {
      origin: origin.upcase,
      destination: destination.upcase,
      start_date: start_date,
      end_date: end_date
    }
    render :index
  end

  def show
    dep = parse_date_param(params[:departure_date])
    if dep.nil?
      redirect_to root_path, alert: "Invalid departure date."
      return
    end

    @flight = Flight.includes(:flight_service, :aircraft).find_by(
      flight_number: params[:flight_number],
      departure_date: dep
    )
    unless @flight
      redirect_to root_path, alert: "Flight not found."
      return
    end
  end

  private

  def parse_date_param(value)
    return nil if value.blank?

    Date.iso8601(value.to_s)
  rescue ArgumentError, TypeError
    nil
  end
end
