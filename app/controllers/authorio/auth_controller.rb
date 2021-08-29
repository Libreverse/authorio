# frozen_string_literal: true

module Authorio
  class AuthController < AuthorioController
    require 'uri'
    require 'digest'

    # These API-only endpoints are protected by code challenge and do not need CSRF protextion
    protect_from_forgery with: :exception, except: %i[send_profile issue_token]

    rescue_from 'Authorio::Exceptions::SessionReplayAttack' do |exception|
      redirect_back_with_error 'Session Replay attack detected. This has been logged.'
      logger.info 'Session replay attack detected!'
      Session.where(user: exception.session.user).delete_all
    end
    rescue_from 'Authorio::Exceptions::UserNotFound' do
      redirect_back_with_error 'User not found'
    end
    rescue_from 'Authorio::Exceptions::InvalidPassword' do
      redirect_back_with_error 'Incorrect password. Try again.'
    end

    # GET /auth
    def authorization_interface
      session.update auth_interface_params.slice(:state, :client_id, :code_challenge, :redirect_uri)
    rescue ActionController::ParameterMissing, ActionController::UnpermittedParameters => e
      render oauth_error 'invalid_request', e
    end

    # POST /user/:id/authorize
    def authorize_user
      redirect_to session[:client_id] and return if params[:commit] == 'Cancel'

      user = authenticate_user_from_session_or_password
      write_session_cookie(user) if auth_user_params[:remember_me]
      redirect_to_client(user)
    end

    def send_profile
      @request = validate_request Request.find_by! code: params[:code]
    rescue Exceptions::InvalidGrant, ActiveRecord::RecordNotFound => e
      render oauth_error 'invalid_grant', e.message
    end

    def issue_token
      @request = validate_request Request.find_by! code: params[:code]
      @token = Token.create_from_request(@request)
    rescue Exceptions::InvalidGrant, ActiveRecord::RecordNotFound => e
      render oauth_error 'invalid_grant', e.message
    end

    def verify_token
      @token = Token.find_by_auth_token(bearer_token) or (head :bad_request and return)
      return unless @token.expired?

      @token.delete
      render token_expired
    end

    private

    def auth_interface_params
      @auth_interface_params ||= begin
        required = %w[client_id redirect_uri state]
        permitted = %w[me scope code_challenge_method response_type action controller code_challenge]
        missing = required - params.keys
        raise ::ActionController::ParameterMissing, missing unless missing.empty?

        unpermitted = params.keys - required - permitted
        raise ::ActionController::UnpermittedParameters, unpermitted unless unpermitted.empty?

        params.permit!
      end
    end

    def scope_params
      params.require(:scope).permit(scope: [])
    end

    def oauth_error(error, message = nil, status = :bad_request)
      { json: { json: { error: error, error_message: message }.compact },
        status: status }
    end

    def token_expired
      oauth_error('invalid_token', 'The access token has expired', :unauthorized)
    end

    def code_challenge_failed?
      # For now, if original request did not have code challenge, then we pass by default
      return unless session[:code_challenge]

      sha256 = Digest::SHA256.hexdigest params[:code_verifier]
      Base64.urlsafe_encode64(sha256) != session[:code_challenge]
    end

    def validate_request(request)
      raise Exceptions::InvalidGrant, 'validation failed' if request.invalid?(params) || code_challenge_failed?

      request
    end

    def redirect_to_client(user)
      auth_req = Request.create(client: session[:client_id],
                                redirect_uri: session[:redirect_uri],
                                scope: (scope_params[:scope].join(' ') if params.key? :scope),
                                authorio_user: user)
      redirect_params = { code: auth_req.code, state: session[:state] }
      redirect_to "#{auth_req.redirect_uri}?#{redirect_params.to_query}"
    end

    def authenticate_user_from_session_or_password
      user_session&.authorio_user or
        User.find_by_username!(auth_user_params[:username])
            .authenticate(auth_user_params[:password]) or
        raise Exceptions::InvalidPassword
    end
  end
end
