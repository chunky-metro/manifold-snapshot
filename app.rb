require 'sinatra'
require 'sinatra/reloader' if development?
require 'erubis'
require './lib/ethereum_spreadsheet.rb'


get '/' do
  erb :index
end

post '/generate' do
  contract_address = params[:contract_address]
  token_number = params[:token_number]

  if contract_address.empty? || token_number.empty?
    @error = "Contract address and token number must be provided."
    return erb :index
  end

  begin
    @spreadsheet = EthereumSpreadsheet.new(contract_address, token_number)
    csv_content =  @spreadsheet.generate
    temp_file = Tempfile.new(['spreadsheet', '.csv'])
    temp_file.write(csv_content)
    temp_file.rewind  # Rewind the file pointer to the beginning
    send_file temp_file.path, :filename => "snapshot-#{Date.today.strftime('%m%d%Y')}.csv", :type => 'text/csv'
  rescue => e
    @error = "An error occurred: #{e.message}"
    erb :index
  end
end
