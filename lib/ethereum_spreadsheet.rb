require 'csv'
require 'http'
class EthereumSpreadsheet
  attr_reader :contract_address, :token_number

  def initialize(contract_address, token_number)
    @contract_address = contract_address
    @token_number = token_number
  end

  def generate
    result = HTTP
      .headers("X-API-KEY" => ENV["MORALIS_API_KEY"])
      .get("https://deep-index.moralis.io/api/v2.2/nft/#{@contract_address}/#{@token_number}/owners?chain=eth&format=decimal")
      .parse(:json)
      .fetch("result")
      
    token_holders = result.map { |res| [res["owner_of"], res["amount"]] }

    content = CSV.generate do |csv|
      csv << ["ownerAddress", "value"]
      token_holders.each do |row|
        csv << row
      end
    end
  end
end
