module ThreshCluster
include("ThreshClusterTypes.jl")
"""This is an API for doing simple clustering with an array of data points and a metric that can be applied to any member of those data points. Ideally, the API for this clustering mechanism should need nothing more than to be passed an array and a distance function and do all the work on its own. We'll see how well that goal works out."""
function threshcluster(array,threshcrit::Threshold_Criteria)
	"""This function will eventually dispatch off of the type of
	threshold criteria (i.e: Kmeans criteria, simple threshold criteria,
	etc.). For now it is just an interface to make_simple_threshold_clusters)"""
	return make_simple_threshold_clusters(array,threshcrit)
end


function make_simple_threshold_clusters(comparray,threshcrit::Threshold_Criteria)
	"""Return an array containing the members of comparray sorted into clusters (subarrays)
	Each subarray contains at least one element, and is indexed by an element from the original array
	i.e: The array at element 4 is an array of elements fulfilling the threshold criteria for element
	4."""
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

function develop_clusters(comparray,threshcrit)
	"""There have been many iterations of this clustering algorithm, and this is by far the fastest and most robust.
	1. Initialize the first cluster. The first cluster is seeded by the first element of 'comparray', or the array of
	objects we want to compare and cluster
	"""

	cluster_container = Any[]
	firstcluster = Cluster(Any[comparray[1]],0,threshcrit.compared_quantity_accessor(comparray[1]))
	cluster_container = vcat(cluster_container,firstcluster)
	for object in comparray[2:end]
		"""Go through each object in array, 
		and we will see whether it should be its own cluster,
		or fit into a different cluster"""
		#Cluster monogamy is a check to see if an object has merged into any clusters at all
		cluster_monogamy = false
		#Cluster polygamy is a check to see if a cluster has merged into more than one cluster
		cluster_polygamy = false
		for clusterid in 1:length(cluster_container)
			"""Now, we are checking each cluster in the cluster container
			to see if our object from the comparray should belong to it"""
			cluster = cluster_container[clusterid]
			#Check is a tuple, the first element is a boolean, whether or not you are in the cluster, the second element is the distance to determine a new modifier if necessary
			check = membership_check(object,cluster,threshcrit) 
			if check[1]
				"i.e: if the object belongs in the cluster"
				if cluster_polygamy
					"""If the object belongs in the cluster and cluster_polygamy is true, 
					that means the object was already included in a different cluster
					This means that this new cluster should be subsumed by the old cluster"""
					cluster_container[the_other_cluster_id] = subsume(cluster_container[the_other_cluster_id],cluster,threshcrit)
				else
					"""Otherwise, the cluster should be inserted into the other cluster, 
					the modifier should be checked against the new object, and the cluster is now marked
					for monogamy (meaning that it has been associated with a cluster and shouldn't be put
					in its own cluster) and polygamy (meaning that any clusters the object
					meets the criteria for membership into should be subsumed by its starting cluster"""
					cluster = insert_into_cluster(object,cluster,threshcrit,check[2])
					cluster_monogamy = true
					cluster_polygamy = true
					global the_other_cluster_id = clusterid
				end
				#=if cluster_polygamy == false=#
					#="=#
					#=cluster_monogamy = true=#
					#=cluster_polygamy = true=#
				#	#=#We have to use a global variable here otherwise Julia will not persist the variable through iterations of the for loop=#
					#=global the_other_cluster_id = clusterid=#
					#=[>@bp<]=#
				#=end=#
			end #End if check[1]
		end #End for cluster in cluster container
		"""If we have gone through each cluster in the container and there is 
		no cluster that our object should be included in, it should seed a new cluster"""
		if cluster_monogamy == false
				new_cluster = Cluster(Any[object],0,threshcrit.compared_quantity_accessor(object))
				cluster_container = vcat(cluster_container,new_cluster)
				"""The cluster is now monogamous, but it doesn't matter as we now 
				move to a different object in the comparray"""
				#=cluster_monogamy = true=#
				
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
		"""i.e: if the distance between the objects is less than 
		our thresholding criteria plus the modifier for the cluster, then it should be included in the cluster"""
		return (true,clusteringdistance)
	else
		return (false,None)
	end
end

function insert_into_cluster(object,cluster,threshcrit,clusteringdistance)
	"""This inserts an object into a cluster's object array, and adjusts the 
	modifier to widen it if the object's distance from the seeder is already larger than the object"""
	cluster.array = vcat(cluster.array,object)
	if clusteringdistance > cluster.modifier
		cluster.modifier = clusteringdistance
	end
	return cluster
end

function subsume(the_other_cluster,cluster,threshcrit)
	"""If an object is to be polyamorous and try to be part of more than one cluster, the cluster it joined first consumes the second cluster
	We then check the seeder distance. If the seeder for the consumed cluster has a distance greater than the cluster's modifier, than 
	the cluster adopts this distanec as its new modifier, the same as if it had had a new object insertion"""
	the_other_cluster.array = vcat(the_other_cluster.array,cluster.array)
	seeder_distances = threshcrit.distance_function(the_other_cluster.seeder,cluster.seeder)
	if seeder_distances > the_other_cluster.modifier
		the_other_cluster.modifier = seeder_distances
	end
	return the_other_cluster
end

end #End module


