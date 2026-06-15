# ============================================================
#   CLI Calculator
#   Supports basic & advanced operations, history tracking,
#   and exports a session log to calculator_history.txt
# ============================================================

# ---------- Helper Methods ----------

def divider(char = "=", length = 45)
  puts char * length
end

def display_menu
  puts "\n  Select an operation:"
  puts "  1. Addition           (+)"
  puts "  2. Subtraction        (-)"
  puts "  3. Multiplication     (*)"
  puts "  4. Division           (/)"
  puts "  5. Modulus            (%)"
  puts "  6. Exponentiation     (**)"
  puts "  7. Square Root        (√)"
  puts "  8. View History"
  puts "  9. Clear History"
  puts "  0. Exit & Save Log"
  puts ""
end

def valid_number?(input)
  input.match?(/^-?\d+(\.\d+)?$/)
end

def get_number(prompt)
  loop do
    print prompt
    input = gets.chomp
    return input.to_f if valid_number?(input)
    puts "  Invalid input. Please enter a valid number."
  end
end

def calculate(op, a, b = nil)
  case op
  when "1" then [a + b,  "#{a} + #{b}"]
  when "2" then [a - b,  "#{a} - #{b}"]
  when "3" then [a * b,  "#{a} * #{b}"]
  when "4"
    return [nil, nil] if b == 0
    [a / b, "#{a} / #{b}"]
  when "5"
    return [nil, nil] if b == 0
    [a % b, "#{a} % #{b}"]
  when "6" then [a ** b, "#{a} ** #{b}"]
  when "7"
    return [nil, nil] if a < 0
    [Math.sqrt(a), "√#{a}"]
  end
end

def format_result(num)
  num == num.to_i ? num.to_i.to_s : num.round(6).to_s
end

# ---------- Main Program ----------

history = []
session_start = Time.now

divider
puts "        RUBY CLI CALCULATOR"
divider
puts "  Tip: results carry forward as 'Ans'"
puts "  Type 'ans' as input to reuse last result"

last_result = nil

loop do
  display_menu
  print "  Your choice: "
  choice = gets.chomp.strip

  break if choice == "0"

  # ---------- View History ----------
  if choice == "8"
    puts ""
    divider("-")
    if history.empty?
      puts "  No calculations yet."
    else
      puts "  CALCULATION HISTORY"
      divider("-")
      history.each_with_index do |h, i|
        puts "  #{(i + 1).to_s.rjust(2)}. #{h}"
      end
    end
    divider("-")
    next
  end

  # ---------- Clear History ----------
  if choice == "9"
    history.clear
    last_result = nil
    puts "\n  History cleared."
    next
  end

  unless %w[1 2 3 4 5 6 7].include?(choice)
    puts "\n  Invalid choice. Please select from the menu."
    next
  end

  # ---------- Square Root (single input) ----------
  if choice == "7"
    print "  Enter number: "
    raw = gets.chomp.strip
    a = if raw.downcase == "ans" && last_result
          puts "  Using Ans = #{format_result(last_result)}"
          last_result
        elsif valid_number?(raw)
          raw.to_f
        else
          puts "  Invalid input."
          next
        end

    result, expression = calculate("7", a)

    if result.nil?
      puts "\n  Error: Cannot take square root of a negative number."
      next
    end

    formatted = format_result(result)
    log_entry = "√#{a} = #{formatted}"
    history << log_entry
    last_result = result

    puts ""
    divider("-")
    puts "  #{expression} = #{formatted}"
    divider("-")
    next
  end

  # ---------- Two-operand Operations ----------
  ops = { "1" => "+", "2" => "-", "3" => "*", "4" => "/", "5" => "%", "6" => "**" }

  print "  Enter first number (or 'ans'): "
  raw_a = gets.chomp.strip
  a = if raw_a.downcase == "ans" && last_result
        puts "  Using Ans = #{format_result(last_result)}"
        last_result
      elsif valid_number?(raw_a)
        raw_a.to_f
      else
        puts "  Invalid input."
        next
      end

  print "  Enter second number (or 'ans'): "
  raw_b = gets.chomp.strip
  b = if raw_b.downcase == "ans" && last_result
        puts "  Using Ans = #{format_result(last_result)}"
        last_result
      elsif valid_number?(raw_b)
        raw_b.to_f
      else
        puts "  Invalid input."
        next
      end

  result, expression = calculate(choice, a, b)

  if result.nil?
    puts "\n  Error: Division or modulus by zero is not allowed."
    next
  end

  formatted = format_result(result)
  log_entry = "#{expression} = #{formatted}"
  history << log_entry
  last_result = result

  puts ""
  divider("-")
  puts "  #{expression} = #{formatted}"
  puts "  Ans = #{formatted}"
  divider("-")
end

# ---------- Session Summary & File Export ----------

puts ""
divider
puts "         SESSION SUMMARY"
divider

if history.empty?
  puts "  No calculations were made this session."
else
  puts "  Total calculations : #{history.size}"
  puts "  Last result        : #{last_result ? format_result(last_result) : "N/A"}"
  puts ""
  puts "  Full History:"
  history.each_with_index do |h, i|
    puts "    #{(i + 1).to_s.rjust(2)}. #{h}"
  end
end

divider

# Save to file
log_path = "calculator_history.txt"
File.open(log_path, "w") do |f|
  f.puts "=" * 45
  f.puts "       CALCULATOR SESSION LOG"
  f.puts "=" * 45
  f.puts "Session start : #{session_start.strftime("%d %b %Y, %I:%M %p")}"
  f.puts "Session end   : #{Time.now.strftime("%d %b %Y, %I:%M %p")}"
  f.puts "-" * 45

  if history.empty?
    f.puts "No calculations recorded."
  else
    f.puts "Total calculations: #{history.size}"
    f.puts "-" * 45
    history.each_with_index do |h, i|
      f.puts "  #{(i + 1).to_s.rjust(2)}. #{h}"
    end
  end

  f.puts "=" * 45
end

puts "\n  Session log saved to '#{log_path}'. Goodbye!"
