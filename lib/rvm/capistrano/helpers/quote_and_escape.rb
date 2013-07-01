require 'rvm/capistrano/helpers/base'

rvm_with_capistrano do
  def quote_and_escape(text, quote = "'")
    "#{quote}#{text.gsub(/#{quote}/) { |m| "#{quote}\\#{quote}#{quote}" }}#{quote}"
  end
end
