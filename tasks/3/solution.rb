class Argument
  def initialize(placeholder, block)
    @placeholder = placeholder
    @block = block
  end

  def call(command_runner, value)
    @block.call(command_runner, value)
  end

  def to_s
    "[#{@placeholder}]"
  end
end

class OptionWithParameter < Argument
  def initialize(short_name, long_name, description, placeholder, block)
    @short_name = short_name
    @long_name = long_name
    @description = description
    super(placeholder, block)
  end

  def name_match?(name)
    name == @short_name || name == @long_name
  end

  def to_s
    "    -#{@short_name}, --#{@long_name}=#{@placeholder} #{@description}"
  end
end

class Option < OptionWithParameter
  def initialize(short_name, long_name, description, block)
    super(short_name, long_name, description, nil, block)
  end

  def to_s
    "    -#{@short_name}, --#{@long_name} #{@description}"
  end
end

class CommandParser
  def initialize(command_name)
    @name = command_name
    @arguments = []
    @options = []
    @options_with_parameters = []
  end

  def argument(*args, &block)
    @arguments.push(Argument.new(*args, block))
  end

  def option(*args, &block)
    @options.push(Option.new(*args, block))
  end

  def option_with_parameter(*args, &block)
    @options_with_parameters.push(OptionWithParameter.new(*args, block))
  end

  def parse_options_with_parameters(argv)
    argv.select do |arg|
      arg.start_with?('--') && arg.include?('=') ||
      arg =~ /^-[[:alnum:]]/ && arg.size > 2
    end
  end

  def call_options_with_parameters(option_names, runner)
    option_pairs = option_names.map do |arg|
      arg.include?('=') ? arg[2..-1].split('=') : [arg[1], arg[2..-1]]
    end
    option_pairs.each do |name, value|
      option = @options_with_parameters.find { |opt| opt.name_match?(name) }
      option ? option.call(runner, value) : nil
    end
  end

  def parse_options(argv)
    argv.select { |arg| arg.start_with? '-', '--' }
  end

  def call_options(option_names, runner)
    option_names.map { |opt| opt.gsub(/^-+/, '') }.each do |name|
      option = @options.find { |opt| opt.name_match?(name) }
      option ? option.call(runner, true) : nil
    end
  end

  def call_arguments(args, runner)
    @arguments.zip(args).each { |arg, value| arg.call(runner, value) }
  end

  def parse(command_runner, argv)
    options_with_parameter = parse_options_with_parameters(argv)
    call_options_with_parameters(options_with_parameter, command_runner)
    options = parse_options(argv - options_with_parameter)
    call_options(options, command_runner)
    args = argv - options
    call_arguments(args, command_runner)
  end

  def help
    [
      ["Usage: #{@name}", @arguments.join(' ')].join(' '),
      @options.join("\n"),
      @options_with_parameters.join("\n")
    ].join("\n")
  end
end
