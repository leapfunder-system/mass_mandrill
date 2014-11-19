module MassMandrill
  class MandrillMailer
    attr_reader :message, :template_content

    def initialize(template_name)
      @template_name = template_name
    end

    def self.method_missing(method_name, *args, &block)
      new(method_name).send(method_name, *args, &block)
    end

    def mail(options)
      @message = build_message(options)
      @template_content = options[:template_content]
      @template_name = options[:template] if options[:template]

      MandrillMail.new(@template_name, @template_content, @message)
    end

    private

    def build_message(options)
      {
        :subject => options[:subject],
        :from_email => from_email(options[:from]),
        :from_name => from_name(options[:from]),
        :to => to(options[:to]),
        :preserve_recipients => options[:preserve_recipients],
        :global_merge_vars => options[:global_merge_vars],
        :merge_vars => options[:merge_vars]
      }.merge(options[:message_extra] || {})
    end

    def to(addresses)
      if addresses.is_a?(Array)
        addresses.map { |address| { :email => address } }
      else
        { :email => addresses }
      end
    end

    def from_email(from)
      scan = scan_email(from)
      scan.blank? ? from : scan.first[1..-2]
    end

    def from_name(from)
      unless scan_email(from).blank?
        from.split(/\</).first.strip
      end
    end

    def scan_email(from)
      from.try(:scan, /\<.*\>/)
    end
  end
end
