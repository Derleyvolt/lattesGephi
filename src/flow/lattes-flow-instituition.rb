require 'csv'
require 'byebug'
require 'progress_bar'

# SELECT kind, place, place_ascii, place_abbr, start_year, end_year, 
#        city, city_ascii, state, country, country_ascii, country_abbr, 
#        latitude, longitude
#   FROM locationslatlon where kind != 'birth' and kind != 'work' and start_year is null and end_year is null order by kind limit 1000;
# degrees_empty = ["doutorado", "ensino-medio", "especializacao", "graduacao", "livre-docencia", "mestrado", "pos-doutorado"]

# locationslatlon_id

def sort_degrees(degrees)
	list = {}
	degrees.each{|deg|
		start_year = deg[6]
		start_year = start_year.to_i unless start_year.nil?
		end_year = deg[7]
		end_year = end_year.to_i unless end_year.nil?

		index = 0
		if start_year.nil? and end_year.nil?
			index = 3000 
		elsif start_year.nil?
			index = end_year 
		elsif end_year.nil?
			index = start_year
		end

		list[index] = deg
	}
	Hash[list.sort].values
end

flow_degrees = [
	"birth",
	"ensino-fundamental",
	"ensino-medio",
	"curso-tecnico",
	"graduacao",
	"aperfeicoamento",
	"residencia",
	"especializacao",
	"mestrado",
	"mestrado-profissionalizante",
	"livre-docencia",
	"doutorado",
	"pos-doutorado",
	"work",
]

ids16 = {}
places = {}
puts "Iniciar"
locations = CSV.read("locationslatlon.csv", col_sep: ';')
locations.shift
bar = ProgressBar.new(locations.size)
puts
countNode = 0
locations.each{|loc|
	bar.increment!
	id16 = loc[1]
	kind = loc[2]
	id = if kind == "birth"
		loc[9]+loc[10]+loc[12]
	else
		loc[4]
	end

	mod_class = if kind == "birth"
		"birth"
	else
		"instituition"
	end
	ids16[id16] ||= {}
	ids16[id16][kind] ||= [] 
	ids16[id16][kind] << loc 
	if places[id].nil?
		countNode += 1
		places[id] = {id: countNode, place: loc[4], class: mod_class,city: loc[9], state: loc[10], country: loc[12], latitude: loc[14], longitude: loc[15]} 
	end
}

csv_string = CSV.generate(:col_sep => ",") do |csv|
	# Id,Label,Modularity Class
	csv << ["Id", "Label", "Modularity Class", "City", "State", "Country", "Latitude", "Longitude"]
	places.each{|index,place|
		csv << [place[:id],place[:place],place[:class],place[:city],place[:state],place[:country],place[:latitude],place[:longitude]]
	}
end
File.write("nodes-flow-instituition.csv", csv_string)

ids16flow = {}
bar = ProgressBar.new(ids16.size)
puts
ids16.each{|id16, degrees|
	bar.increment!
	ids16flow[id16] = []
	flow_degrees.each{|degree|
		unless degrees[degree].nil? 
			if degrees[degree].size == 1
				ids16flow[id16] << degrees[degree].first
			else
				sort_degrees(degrees[degree]).each{|deg|
					ids16flow[id16] << deg
				}
			end
		end
	}
}

edges = []
bar = ProgressBar.new(ids16flow.size)
puts
ids16flow.each{|id16, locations|
	bar.increment!
	if locations.size > 1
		source = nil
		locations.each{|location|
			target = location
			edges << {source: source, target: target} unless source.nil?
			source = target
		}
	end
}

byebug
edges_clean = {}
bar = ProgressBar.new(edges.size)
puts
edges.each{|edge|
	bar.increment!
	source = edge[:source]
	target = edge[:target]
	id = if source[2] == "birth"
		source[9]+source[10]+source[12]+target[2]
	else
		source[4]+target[2]
	end
	if edges_clean[id].nil?
		edges_clean[id] = edge 
		edges_clean[id][:weight] = 1
	else
		edges_clean[id][:weight] += 1
	end
}

network = []
countEdge = 0 
bar = ProgressBar.new(edges_clean.size)
puts
edges_clean.each{|index, edge|
	bar.increment!

	source = edge[:source]
	source_kind = source[2]
	id = if source_kind == "birth"
		source[9]+source[10]+source[12]
	else
		source[4]
	end
	source = places[id][:id]

	target = edge[:target]
	target_kind = target[2]
	id = if target_kind == "birth"
		target[9]+target[10]+target[12]
	else
		target[4]
	end
	target = places[id][:id]
	
	kind = if source_kind == "birth"
		"birth"
	elsif target_kind == "work"
		"work"
	else
		"degree"
	end
	
	countEdge += 1
	# Source,Target,Type,Id,Label,Weight
	network << [source, target, kind, "Directed", countEdge, nil, edge[:weight]]
}

csv_string = CSV.generate(:col_sep => ",") do |csv|
	csv << ["Source", "Target","Kind","Type", "Id", "Label", "Weight"]
	network.each{|edge|
		csv << edge
	}
end
File.write("edges-flow-instituition.csv", csv_string)

puts "fim"
