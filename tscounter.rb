
debugMode = false

class TimestampProcessor
  attr_accessor :currentDate, :fp, :numHits

  def initialize(f)
    @fp = File.open(f)
    @currentDate = ""
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
      @currentDate = "%4d/%02d/%02d" % [a,b,c]
    in /(\d\d):(\d\d)_(.M)/
      (hour, min, pm) = [$1.to_i, $2.to_i, $3.downcase]
      if pm =~ /pm/ && (hour < 12)
        hour += 12
      end
      timestamp = "%s,%02d:%02d" % [@currentDate, hour, min]
      if @last_timestamp == timestamp
        @numHits += 1
      else
        puts timestamp
        @last_timestamp = timestamp
        @numHits = 0
      end
    else
      # Lines that don't match are ignored
    end
  end
end

errorFlag = false
(fileName, num_lines) = ARGV.map {|i| i.match(/\D/) ? i : i.to_i }

unless fileName =~ /\W+/ && num_lines.is_a?(Integer)
  puts "Useage:\n#{__FILE__} filename no_lines"
  errorFlag = true
end

unless File.exist? fileName
  puts "#{fileName} does not exist."
  errorFlag = true
end

exit 0 if errorFlag

tsp = TimestampProcessor.new(fileName)

tsp.run num_lines
