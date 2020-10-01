# frozen_string_literal: true

# CheckCertificateJob will iterate over all the Domain objects stored and call the method #check_certificate on it
class CheckCertificateJob < ApplicationJob
  def perform(*_args)
    if Domain.all.count.zero?
      Rails.logger.info('No domains are tracked as of now, please insert domains to be tracked')
      return
    end
    Domain.all.each do |domain|
      if domain.certificate_expiring?
        Rails.logger.info("#{domain.fqdn} is expiring within the buffer period")
        if (Figaro.env.send_expiry_notifications_to_slack == true) && (Figaro.env.slack_webhook_url != '')
          message = "Your #{domain.fqdn} is expiring at #{domain.certificate_expiring_not_before}, please renew your cert"
          slack_notifier = SlackNotifier.new(Figaro.env.slack_webhook_url)
          slack_notifier.notify(message)
        end
      else
        Rails.logger.info("#{domain.fqdn} is not expiring within the buffer period")
      end
    end
  end
end
