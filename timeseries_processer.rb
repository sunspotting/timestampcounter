#! /usr/bin/env ruby

# Public: Process a TimeSeries file
module TimeSeriesProcessor
  def self.run(args)
    error_flag = false
    file_name = args[0]

    unless File.exist? file_name
      puts "#{file_name} does not exist."
      error_flag = true
    end

    exit 0 if error_flag

    TimestampProcessor.new(file_name).run
  end

  # Internal: Holds state while processing file
  class TimestampProcessor
    def initialize(file_name)
      @fp = File.open(file_name)
      @current_date = nil
      @num_hits_day = 0
      @num_hits_total = 0
      @num_days = 0
      @first_time = true
    end

    def run
      while (line = @fp.gets)
        process_line line
        next unless @fp.eof # next unless last line of file, dump last state

        puts format('%<date>s, %<hits>d', date: @current_date, hits: @num_hits_day)
        puts format('Total hits: %<total>d', total: @num_hits_total)
        puts format('Avg hits/day: %<avg>d', avg: @num_hits_total/@num_days)
      end
    end

    def first_time?
      ret_val = @first_time
      @first_time = false
      return ret_val
    end

    def process_line(line)
      case line
      in /:(\d\d\d\d)-(\d\d)-(\d\d)_.+:/    # date
        puts format('%<data>s, %<hits>d', data: @current_date, hits: @num_hits_day) unless first_time?
        @current_date = format('%<year>4d-%<month>02d-%<day>02d', year: Regexp.last_match(1).to_i,
                                                                  month: Regexp.last_match(2).to_i,
                                                                  day: Regexp.last_match(3).to_i)
        @num_hits_day = 0
        @num_days += 1
      in /(\d\d):(\d\d)_(.M)/               # time
        @num_hits_day += 1
        @num_hits_total += 1
      else # ignore all else
      end
    end
  end
end

TimeSeriesProcessor.run(ARGV)

__END__
Go.state(:also) do |also|

  also.

end
