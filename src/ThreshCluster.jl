module ThreshCluster
include("ThreshClusterTypes.jl")
using Debug
type Cluster
	array #The actual array of objects that forms the cluster
	modifier #The largest distance between two objects in the cluster, which acts to widen the threshold for inclusion to a cluster
	seeder # The object that this cluster was seeded from
end

function make_simple_threshold_clusters(comparray,threshcrit::Threshold_Criteria)
	if !(typeof(comparray) <: Array)
		comparray = Any[comparray]
	end
	if length(comparray) < 1
		return []
	elseif length(comparray) < 2
		return comparray
	else
		clustered_array = develop_clusters(comparray,threshcrit)
		clustered_array = map(x->unique(x.array),clustered_array)
		return clustered_array
	end
end


export make_simple_threshold_clusters

@debug function develop_clusters(comparray,threshcrit)
	"""Now all about the mutable state, no functions, only subroutines:
	(Here's the pseudocode implementation:
	for each object in the array:
		1. Check to see if the object fits in a cluster built off a formerly seeded quantity
			if so:
				if it has already been put into an array:
					that other array eats the array we're thinking about
				otherwise:
					put it in that cluster's array
			if not:
				put it in its own cluster, and start the array with that object
	This should be a super simple implementation of all the logic we had before"""
	cluster_container = Any[]
	firstcluster = Cluster(Any[comparray[1]],0,threshcrit.compared_quantity_accessor(comparray[1]))
	cluster_container = vcat(cluster_container,firstcluster)
	for object in comparray[2:end]
		#Cluster monogamy is a check to see if an object has merged into any clusters at all
		cluster_monogamy = false
		#Cluster polygamy is a check to see if a cluster has merged into more than one cluster
		cluster_polygamy = false
		for clusterid in 1:length(cluster_container)
			cluster = cluster_container[clusterid]
			#Check is a tuple, the first element is a boolean, whether or not you are in the cluster, the second element is the distance to determine a new modifier if necessary
			check = membership_check(object,cluster,threshcrit) 
			#If object belongs in cluster
			if check[1]
				#Put object into cluster
				if cluster_polygamy
					#=@bp=#
					cluster_container[the_other_cluster_id] = subsume(cluster_container[the_other_cluster_id],cluster,threshcrit)
				else
					cluster = insert_into_cluster(object,cluster,threshcrit,check[2])
					cluster_monogamy = true
					cluster_polygamy = true
					global the_other_cluster_id = clusterid
				end
				if cluster_polygamy == false
					cluster_monogamy = true
					cluster_polygamy = true
					global the_other_cluster_id = clusterid
					#=@bp=#
				end
			end
		end #End for cluster in cluster container
		if cluster_monogamy == false
				new_cluster = Cluster(Any[object],0,threshcrit.compared_quantity_accessor(object))
				cluster_container = vcat(cluster_container,new_cluster)
				cluster_monogamy = true
				
		end
	end #end for object in comparray
	return cluster_container
end #end function

function membership_check(object,cluster,threshcrit)
	"Checks to see if an object should join a cluster"
	"quant refers to the clustering quantity, a field on an object"
	objectquant = threshcrit.compared_quantity_accessor(object)
	clusterbasequant = cluster.seeder
	clusteringdistance = threshcrit.distance_function(objectquant,clusterbasequant)
	if clusteringdistance <= threshcrit.threshold+cluster.modifier
		return (true,clusteringdistance)
	else
		return (false,None)
	end
end

function insert_into_cluster(object,cluster,threshcrit,clusteringdistance)
	cluster.array = vcat(cluster.array,object)
	if clusteringdistance > cluster.modifier
		cluster.modifier = clusteringdistance
	end
	return cluster
end

function subsume(the_other_cluster,cluster,threshcrit)
	"If an object is found to be polygamous (wants to belong to more than one cluster), the first cluster it wanted to be in subsumes the second"
	the_other_cluster.array = vcat(the_other_cluster.array,cluster.array)
	seeder_distances = threshcrit.distance_function(the_other_cluster.seeder,cluster.seeder)
	if seeder_distances > the_other_cluster.modifier
		the_other_cluster.modifier = seeder_distances
	end
	return the_other_cluster
end

end #End module


