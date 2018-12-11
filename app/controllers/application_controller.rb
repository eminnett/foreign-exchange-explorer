# frozen_string_literal: true

class ApplicationController < ActionController::Base
  class BadParams < StandardError; end

  def bad_request(message=nil)
    render json: {
      status:  400,
      error:   :bad_request,
      message: (message || "Unable to process the request due to a client error.")
    }, status: :bad_request
  end

  def not_found(message=nil)
    render json: {
      status:  404,
      error:   :not_found,
      message: (message || "The requested resource(s) could not be found.")
    }, status: :not_found
  end

  def handle_internal_server_error(_error, message=nil)
    # TODO: Add error logging to capture and report the error message.
    render json: {
      status:  500,
      error:   :internal_server_error,
      message: (message || "Something went wrong while processing your request")
    }, status: :internal_server_error
  end
end
