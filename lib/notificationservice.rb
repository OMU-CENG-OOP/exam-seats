require 'csv'

# Kanal-bagimsiz bildirim servisi sablonu.
# Runner sadece `notify(exam)` cagirir; aktif kanal hangi sinifsa o kullanilir.
class NotificationService
  attr_reader :student_directory, :lists_path, :config

  # `config`, aktif bildirici kanalinin ayarlarini tasir.
  # Ornek: webhook_url, token, channel_id, sender bilgisi vb.
  def initialize(student_directory, lists_path: 'Lists', config: {})
    @student_directory = student_directory
    @lists_path = lists_path
    @config = config
  end

  def notify(exam)
    notifications = build_notifications(exam)
    notifications.each do |notification|
      deliver(notification)
    end

    notifications
  end

  def channel_name
    raise NotImplementedError, "#{self.class}#channel_name ogrenci tarafindan doldurulacak."
  end

  private

  def build_notifications(exam)
    recipients_for(exam).map do |recipient|
      build_notification(exam: exam, recipient: recipient)
    end.compact
  end

  def recipients_for(exam)
    csv_path = roster_csv_path(exam.course_name)

    CSV.foreach(csv_path, headers: true).map(&:to_h)
  end

  def build_notification(exam:, recipient:)
    student_no = recipient['student_no']
    student = lookup_student(student_no)

    {
      channel: channel_name,
      exam: exam,
      student_no: student_no,
      student: student,
      recipient: recipient,
      message: notification_message(
        exam: exam,
        student_no: student_no,
        student: student,
        recipient: recipient
      )
    }
  end

  def notification_message(exam:, student_no:, student:, recipient:)
    raise NotImplementedError, "#{self.class}#notification_message ogrenci tarafindan doldurulacak."
  end

  def deliver(notification)
    raise NotImplementedError, "#{self.class}#deliver ogrenci tarafindan doldurulacak."
  end

  def roster_csv_path(course_name)
    File.join(lists_path, "#{course_name}.csv")
  end

  def lookup_student(student_no)
    return nil unless student_directory.respond_to?(:find)

    student_directory.find(student_no)
  end
end

# Baslangic kanali. Ileride Slack, Discord, SMS vb. siniflar bunun gibi
# NotificationService'den kalitim alabilir.
class ConsoleNotificationService < NotificationService
  def channel_name
    'console'
  end

  private

  def deliver(notification)
    puts notification[:message]
  end
end

# Gelecekte yapilabilecek farkli bildirim ornekleri:
=begin

##############################################################################

class SlackNotificationService < NotificationService
  def channel_name
    'slack'
  end

  private

  def notification_message(exam:, student_no:, student:, recipient:)
    # Ornek: Slack icin ogrenciye ozel mesaj metni burada uretilir.
  end

  def deliver(notification)
    webhook_url = config[:webhook_url]
    channel = config[:channel]

    # TODO: Slack webhook ya da Slack API ile bildirim gonder.
  end
end

##############################################################################

class GmailChatNotificationService < NotificationService
  def channel_name
    'gmail_chat'
  end

  private

  def notification_message(exam:, student_no:, student:, recipient:)
    # Ornek: Gmail / Google Chat icin mesaj govdesi burada uretilir.
  end

  def deliver(notification)
    access_token = config[:access_token]
    room_id = config[:room_id]

    # TODO: Google Chat API ya da ilgili servis ile bildirim gonder.
  end
end

##############################################################################

class DiscordNotificationService < NotificationService
  def channel_name
    'discord'
  end

  private

  def notification_message(exam:, student_no:, student:, recipient:)
    # Ornek: Discord mesaj formati burada uretilir.
  end

  def deliver(notification)
    webhook_url = config[:webhook_url]

    # TODO: Discord webhook ile bildirim gonder.
  end
end

##############################################################################

class SmsNotificationService < NotificationService
  def channel_name
    'sms'
  end

  private

  def notification_message(exam:, student_no:, student:, recipient:)
    # Ornek: SMS icin daha kisa mesaj metni burada uretilir.
  end

  def deliver(notification)
    api_key = config[:api_key]
    sender_id = config[:sender_id]

    # TODO: SMS saglayicisinin API'si ile bildirim gonder.
  end
end

##############################################################################
=end
