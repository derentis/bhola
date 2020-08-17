module Api
  module V1
    class DomainsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        fqdn = params.require(:fqdn)

        domain = Domain.new(fqdn: fqdn)
        if domain.valid?
          domain.save!
          render :json => {:data => { 'fqdn': fqdn }, :errors => []}, status: :created and return
        end
        render :json => {:data => { 'fqdn': fqdn }, :errors => ['domain already is already being tracked']},
               status: :unprocessable_entity and return
      end

      def show
        domain = Domain.find_by_id(params[:id])
        if domain
          render :json => {:data => {'fqdn': domain.fqdn, 'certificate_expiring': domain.certificate_expiring },
                           :errors => []}, status: :ok and return
        end
      end
    end
  end
end
