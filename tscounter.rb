#! /usr/bin/env ruby

module TimeSeriesProcessor
  def TimeSeriesProcessor.run(args)
    error_flag = false
    (file_name, num_lines) = args.map { |i| i.match(/\D/) ? i : i.to_i }

    unless file_name =~ /\W+/ && num_lines.is_a?(Integer)
      puts "Useage:\n#{__FILE__} filename no_lines"
      error_flag = true
    end

    unless File.exist? file_name
      puts "#{file_name} does not exist."
      error_flag = true
    end

    exit 0 if error_flag

    tsp = TimestampProcessor.new(file_name)
    tsp.run num_lines
  end

  class TimestampProcessor
    def initialize(file_name)
      @fp = File.open(file_name)
      @current_date = ''
      @num_hits = 0
      @last_timestamp = ''
    end

    def run(num_lines)
      num_lines.times do
        line = @fp.gets
        process_line line
        if @fp.eof # if last line of file, dump last
          puts "%s, %d" % [@last_timestamp, @num_hits]
          break
        end
      end
    end

    def process_line(line)
      case line 
      in /:(\d\d\d\d)-(\d\d)-(\d\d)_.+:/
        (a,b,c) = [$1,$2,$3].map(&:to_i)
        @current_date = '%4d/%02d/%02d' % [a,b,c]
      in /(\d\d):(\d\d)_(.M)/
        (hour, min, pm) = [$1.to_i, $2.to_i, $3.downcase]
        if pm =~ /pm/ && (hour < 12)
          hour += 12
        end
        timestamp = '%s,%02d:%02d' % [@current_date, hour, min]
        if @last_timestamp.empty? # first time matching
          @num_hits += 1
          @last_timestamp = timestamp
        elsif @last_timestamp == timestamp # repeat
          @num_hits += 1
        else # not the same 
          # print last match in cycle
          puts "%s, %d" % [@last_timestamp, @num_hits]
          # start new cycle
          @last_timestamp = timestamp
          @num_hits = 1
        end
      else
        # Lines that don't match are ignored
      end
    end
  end
end

TimeSeriesProcessor.run(ARGV)
