#! /usr/bin/env ruby

module TimeSeriesProcessor

  def TimeSeriesProcessor.run(args)
    error_flag = false
    file_name = args[0]

    unless File.exist? file_name
      puts "#{file_name} does not exist."
      error_flag = true
    end

    exit 0 if error_flag

    tsp = TimestampProcessor.new(file_name)
    tsp.run 
  end

  class TimestampProcessor
    def initialize(file_name)
      @fp = File.open(file_name)
      @current_date = nil
      @num_hits_day = 0
      @num_hits_total = 0
      @last_date = nil
    end

    def run
      while (line = @fp.gets) do
        process_line line
        if @fp.eof # if last line of file, dump last
          puts "%s, %d" % [@current_date, @num_hits_day]
          puts "Total hits: %d" % [@num_hits_total]
          break
        end
      end
    end

    def first_time?
      !@last_date # true when nil
    end

    def process_line(line)
      case line 
      in /:(\d\d\d\d)-(\d\d)-(\d\d)_.+:/
        puts "%s, %d" % [@current_date, @num_hits_day] unless first_time?
        (a,b,c) = [$1,$2,$3].map(&:to_i)
        @current_date = '%4d-%02d-%02d' % [a,b,c]
        @num_hits_day = 0
        @last_date = @current_date
      in /(\d\d):(\d\d)_(.M)/
        @num_hits_day += 1
        @num_hits_total += 1
      else
        # ignore all else
      end
    end
  end
end

TimeSeriesProcessor.run(ARGV)

__END__
Go.state(:also) do |also|

  also.

end
