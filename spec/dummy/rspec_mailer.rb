class RspecMailer
  class << self
    def send!(data, to)
      mailto(to, data.body)
    end

    def welcome(data, to)
      mailto(to, "From welcome!\n#{data.body}")
    end

    private

    def mailto(to, body)
      "Mail to #{to} with body #{body}"
    end
  end
end