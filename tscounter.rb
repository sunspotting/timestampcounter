#! /usr/bin/env ruby
class TimestampProcessor
  attr_accessor :current_date, :fp, :num_hits

  def initialize(f)
    @fp = File.open(f)
    @current_date = ''
  end

  def run(num_lines)
    counter = 0
    num_lines.times do
      line = @fp.gets
      break if @fp.eof
      process_line line
      counter += 1
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
      if @last_timestamp == timestamp
        @num_hits += 1
      else
        puts timestamp
        @last_timestamp = timestamp
        @num_hits = 0
      end
    else
      # Lines that don't match are ignored
    end
  end
end

error_flag = false
(file_name, num_lines) = ARGV.map { |i| i.match(/\D/) ? i : i.to_i }

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
