require 'csv'
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def clean_phone_numbers(number)
  number.gsub!(/[()-. ]/, '').to_s
  if number.length == 11  && number[0] == "1"
    number[1..10]
  elsif number.length >= 11 || number.length < 10
    "0000000000"
  else
    "(#{number[0..2]})-#{number[3..5]}-#{number[6..9]}"
  end
end

def format_date(registation_date)
  DateTime.strptime(registation_date,'%Y')
  #DateTime.hour(registation_date)
end


def save_thank_you_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager Initialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters:
:symbol

template_letter = File.read("form_letter.erb")
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_numbers(row[:homephone])
  registation_date = format_date(row[:regdate]).to_s

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)


  save_thank_you_letters(id, form_letter)

  puts clean_phone_numbers(phone_number)
  puts format_date(registation_date)
end
