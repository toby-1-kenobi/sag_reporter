json.array!(@tallies) do |tally|
  json.extract! tally, :id, :name, :description
  json.url tally_url(tally, format: :json)
end
